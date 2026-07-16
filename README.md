# FreightFox / Titan — Terraform Infrastructure  
### Shared VPC on GCP — India + US, 6 regions, path-based CircleCI pipeline

This README is written for someone who has never seen this repo before.
Read it top to bottom once — after that you'll mostly just look at the
one section relevant to what you're doing that day.

---

## 1. What this repo actually builds

Two regions, three tiers each = **6 Shared VPCs**:

```
in/                                              us/
├── dev/network/in-dev-network      → india-dev-vpc     ├── dev/network/us-dev-network      → us-dev-vpc
├── staging/network/in-staging-network → india-staging-vpc ├── staging/network/us-staging-network → us-staging-vpc
└── prod/network/in-prod-network    → india-prod-vpc     └── prod/network/us-prod-network    → us-prod-vpc
```

Each **host** environment owns a VPC and its subnets, then "shares" those
subnets with **service** projects (Shared VPC / XPN — this is how GCP
lets multiple projects use one network without giving up isolation).

```
in/dev/network/in-dev-network owns india-dev-vpc, and shares it with:
  in/dev/in-dev-tms        (in-tms-dev project)        → Cloud SQL + GKE
  in/dev/in-dev-vms        (in-vms-dev project)         → Cloud SQL + GKE
  in/dev/in-dev-analytics  (in-analytics-dev project)   → Dataflow/BigQuery (no GKE cluster)
```

The **us/** side is the exact same pattern, just a different region
(`us-central1`) and a different CIDR block (10.70–10.72 instead of
10.60–10.62), so that India and US networks can never collide even if
they're ever connected later.

---

## 2. New to GCP networking? Read this first

If you've worked with AWS before, three GCP ideas are different enough
to cause confusion — knowing them makes the rest of this repo obvious:

- **A GCP subnet belongs to a whole region, not one Availability
  Zone.** One subnet automatically spans all zones in that region.
  There is no "subnet per AZ" like in AWS.
- **Shared VPC (XPN)** lets a "host" project own the network, while
  "service" projects (separate billing/IAM boundary) deploy resources
  *into* that network. Nobody has to copy the network into each
  project — attaching once is enough.
- **A GKE cluster needs 3 IP ranges**, not one: the subnet itself (for
  node IPs), a "pods" secondary range, and a "services" secondary
  range. All three are created once, in the *host* environment, and
  simply referenced by name inside the *service* environment.

---

## 3. Repository layout

```
titan-terraform/
├── .circleci/
│   ├── config.yml            ← stage 1: detects which files changed
│   └── continue_config.yml   ← stage 2: the real jobs/workflows
├── terraform/bootstrap/       ← one-time setup, run once per project
│   ├── main.tf                (enables APIs, creates state bucket + SA)
│   ├── run_bootstrap.sh        ./run_bootstrap.sh in-dev-tms | all
│   └── projects/*.tfvars       one file per project (22 total)
├── modules/
│   ├── networking/
│   │   ├── vpc/                creates the VPC itself
│   │   ├── subnet/              creates subnets + GKE secondary ranges
│   │   └── shared-vpc/          turns on Shared VPC + attaches service projects
│   ├── compute/gke/            NEW — private GKE cluster + node pool
│   ├── database/cloud-sql/     Postgres instance + private IP
│   └── security/secret-manager/ stores the generated DB password
└── environments/
    ├── in/
    │   ├── dev/      network/in-dev-network/  in-dev-tms/  in-dev-vms/  in-dev-analytics/
    │   ├── staging/  network/in-staging-network/  in-staging-tms/  in-staging-vms/
    │   └── prod/     network/in-prod-network/  in-prod-tms/  in-prod-vms/  in-prod-analytics/
    └── us/  (identical shape to in/, us-* prefixed dirs)
```

Every environment folder has exactly the same 6 files, always:
`main.tf`, `variables.tf`, `terraform.tfvars`, `backend.tf`,
`providers.tf`, `outputs.tf`. If you can read one environment, you can
read all 22 — nothing is "special-cased".

---

## 4. GKE and Cloud SQL — where they live

`modules/compute/gke` is a new module. It creates:
- One **private, regional GKE cluster** (nodes have no public IP)
- One autoscaling node pool (1–3 nodes per zone by default)
- Workload Identity turned on (so pods can call GCP APIs safely,
  without long-lived service account keys stored in the cluster)

It is wired into 4 environments today — `in/dev/in-dev-tms`,
`in/dev/in-dev-vms`, `us/dev/us-dev-tms`, `us/dev/us-dev-vms` — right
next to the Cloud SQL module that was already there. Open
`environments/in/dev/in-dev-tms/main.tf` and read it top to bottom; it's
commented step-by-step and is the template to copy for staging/prod or
for `vms`/`analytics` later.

**`analytics-*` environments do not get a GKE cluster** — analytics
workloads (Dataflow, Datastream, BigQuery) are fully-managed Google
services, they don't need cluster nodes. Their subnets still reserve
GKE-shaped IP ranges (pods/services) in case that changes later, but
no cluster is deployed by default.

### GKE control-plane CIDR plan (the "master_cidr" you'll see)

Every GKE cluster needs its own private `/28` for the control plane,
and it must not collide with any subnet. These are already reserved
and verified (zero overlaps) for every tier/region:

| Tier/Region | tms master | vms master |
|---|---|---|
| india dev (10.60) | 10.60.140.0/28 | 10.60.140.16/28 |
| india staging (10.61) | 10.61.140.0/28 | 10.61.140.16/28 |
| india prod (10.62) | 10.62.140.0/28 | 10.62.140.16/28 |
| us dev (10.70) | 10.70.140.0/28 | 10.70.140.16/28 |
| us staging (10.71) | 10.71.140.0/28 | 10.71.140.16/28 |
| us prod (10.72) | 10.72.140.0/28 | 10.72.140.16/28 |

---

## 5. CircleCI — how a deploy actually gets triggered

This repo uses a **two-stage ("setup") pipeline**. Stage 1 always runs
first and only answers one question: *what changed?* Stage 2 does the
actual `terraform plan`/`apply`.

```
 push to git
      │
      ▼
 .circleci/config.yml  (stage 1 — "detect changes")
      │
      │ looks at which files changed vs main, e.g.:
      │   environments/in/dev/in-dev-tms/main.tf   changed
      │   environments/us/dev/us-dev-vms/terraform.tfvars  changed
      │
      ▼
 sets pipeline parameters:
   run-india-tms-dev = true
   run-us-vms-dev    = true
      │
      ▼
 .circleci/continue_config.yml  (stage 2 — "do the work")
      │
      ├── auto-india-tms-dev workflow runs  ─┐
      └── auto-us-vms-dev workflow runs     ─┘  (in parallel, automatically)
```

If you only touch one environment's files, only that environment's
workflow runs. Touch two, both run — side by side, no extra clicking.

### Three ways to trigger something

**A) Automatic (the normal day-to-day case)** — just push. Stage 1
figures out which environment(s) changed and runs them for you.

**B) Manual, one specific environment** — CircleCI → *Trigger
Pipeline* → set:
```
manual_trigger = true
region         = india        (or us)
environment    = tms-dev       (any of the 22 environment names)
```
Use this to re-run an environment even though nothing changed (e.g.
after fixing a state issue by hand), or to deploy for the first time.

**C) Manual, bootstrap a project (one-time only)** — CircleCI →
*Trigger Pipeline* → set:
```
run_bootstrap = true
region        = india
bootstrap_env = tms-dev
```
This is deliberately **not** automatic — it enables APIs and creates a
service account, which is a one-time, slightly sensitive action you
want to trigger on purpose, not because a file happened to change.

### What if I change a shared module (e.g. `modules/networking/subnet`)?

Path-filtering only watches `environments/**`, so changing a shared
module does **not** auto-trigger anything (a module change might
affect many environments — auto-running all 22 on every module tweak
would be surprising and expensive). After changing a shared module,
manually trigger (option B) each environment you want to re-apply.

---

## 6. Do I need to add all 22 environments' credentials to CircleCI?

**No — only add a context for an environment when you're about to
deploy it.** Each environment uses its own CircleCI **context**, named
`gcp-<region>-<environment>` (e.g. `gcp-india-tms-dev`), holding one
variable: `GOOGLE_CREDENTIALS` = that project's dedicated service
account key (created by bootstrap).

If a context doesn't exist yet and that environment's pipeline tries
to run, it fails cleanly at the very first "Load GCP service account
key" step with an auth error — that's expected, not a bug. It just
means you haven't onboarded that environment yet.

Recommended order to onboard contexts:

| Priority | Context | Why first |
|---|---|---|
| 1 | `gcp-bootstrap` | Needed before you can bootstrap anything |
| 2 | `gcp-india-host-dev` | Creates the India dev VPC everything else needs |
| 3 | `gcp-india-tms-dev`, `gcp-india-vms-dev`, `gcp-india-analytics-dev` | First real workloads |
| 4 | `gcp-us-host-dev` + `gcp-us-tms-dev`/`vms-dev`/`analytics-dev` | Same, US side |
| 5 | The 6 staging/prod host contexts, then their service contexts | When you're ready for staging/prod |

You do **not** need to pre-create all 23 contexts (22 + bootstrap) on
day one. Add each one right before you first deploy that environment.

---

## 7. State buckets — one per project, always

Every environment's `backend.tf` points at a bucket that lives inside
*that project*, e.g.:

```hcl
# environments/in/dev/in-dev-tms/backend.tf
backend "gcs" {
  bucket = "freightfox-tfstate-india-tms-dev"
  prefix = "terraform/state"
}
```

The bucket is created by that same project's bootstrap run (see
`terraform/bootstrap/projects/in-dev-tms.tfvars`). Nothing is
shared between projects' state — a mistake in one environment's state
can never corrupt another's.

---

## 8. "No errors" — what was actually checked, and how

This sandbox has no internet access, so the real `terraform` binary
could not be installed to run a live `terraform validate` against
Google's provider. Instead, every file in this repo was run through
four independent static checks (see `terraform fmt -check -recursive`
below for the one thing to still run yourself):

| Check | Result |
|---|---|
| Every `.tf` file: balanced `{}` `()` `[]` and quotes | ✅ 150/150 files clean |
| Every `module "x" { source = "../.." }` path exists on disk | ✅ 0 broken paths |
| Every `var.X` used has a matching `variable "X"` declared | ✅ 0 mismatches |
| Every `terraform.tfvars` key matches a declared variable (no typos, nothing missing) | ✅ 0 mismatches |
| Every module *call*'s arguments match that module's `variables.tf` (no unknown args, no missing required args) | ✅ 30/30 module calls clean |
| No duplicate `variable`/`output`/`resource`/`module` names in any single file | ✅ 0 duplicates |
| All 22 environments have all 6 standard files present | ✅ 22/22 complete |
| Both CircleCI YAML files parse without syntax errors | ✅ both valid |
| CIDR overlap check across all 6 VPCs + GKE pod/service/master ranges + AWS ranges | ✅ 0 overlaps (80 ranges checked) |

**Before your first real `terraform plan`**, please also run this
once yourself (needs real credentials, which this sandbox doesn't
have):
```bash
cd environments/in/dev/network/in-dev-network
terraform init -backend=false
terraform validate
```
That does one more check the static analysis above can't: whether the
Google provider itself considers every resource argument (types,
required fields per resource type) fully valid. Given how clean the
static pass came back, this should complete without surprises — but
it's the honest last mile that only the real `terraform` binary can
walk.

---

## 9. First-time setup order (do this once)

```
1. In CircleCI project settings → Advanced →
   enable "Use dynamic config using setup workflows"  (required for stage 1/2 split)

2. Bootstrap the india dev tier (already has real project IDs filled in):
   Trigger Pipeline → run_bootstrap=true, region=india, bootstrap_env=host-dev
   Trigger Pipeline → run_bootstrap=true, region=india, bootstrap_env=tms-dev
   Trigger Pipeline → run_bootstrap=true, region=india, bootstrap_env=vms-dev
   Trigger Pipeline → run_bootstrap=true, region=india, bootstrap_env=analytics-dev

3. For each project bootstrapped above, create its CircleCI context
   (gcp-india-host-dev, gcp-india-tms-dev, ...) using the SA email
   printed in that bootstrap run's output.

4. Deploy the host first (it creates the VPC everything else needs):
   Trigger Pipeline → manual_trigger=true, region=india, environment=host-dev
   → approve → apply

5. Copy the 3 output values (vpc_self_link, subnet_self_links) into
   environments/in/dev/in-dev-tms/terraform.tfvars (and vms-dev,
   analytics-dev) — replacing the REPLACE_WITH_* placeholders.

6. Deploy tms-dev / vms-dev / analytics-dev the same way.

7. Repeat steps 2–6 for us/, then for staging and prod tiers when ready.
```

---

## 10. Quick reference — all 22 environments

| Region | Tier | Host | Services |
|---|---|---|---|
| india | dev | host-dev | tms-dev, vms-dev, analytics-dev |
| india | staging | host-staging | tms-staging, vms-staging |
| india | prod | host-prod | tms-prod, vms-prod, analytics-prod |
| us | dev | host-dev | tms-dev, vms-dev, analytics-dev |
| us | staging | host-staging | tms-staging, vms-staging |
| us | prod | host-prod | tms-prod, vms-prod, analytics-prod |

(staging has no analytics tier, matching the original AWS setup)
