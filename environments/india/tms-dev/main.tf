# =================================================================       
# ENVIRONMENT: india/tms-dev   (service project: india-tms-dev) 
#
# Deploys into the Shared VPC owned by india/host-dev.
# This file does THREE things, in order:
#   1. Opens a private-services connection so Cloud SQL can get a
#      private IP inside the host VPC (no public IP, ever).
#   2. Creates the Cloud SQL (Postgres) instance + a GKE cluster,
#      both living inside the "tms-dev-private" subnet that the
#      host-dev environment already created.
#   3. Stores the generated DB password in Secret Manager so nobody
#      has to email/Slack it around.
#
# NOTHING here creates a VPC or subnet - that already exists,
# created by india/host-dev. If you're not sure what a subnet
# or CIDR is, see the "New to GCP networking?" section in README.md
# at the repo root.
# =================================================================

# ---- 1. Private Service Access (PSA) for Cloud SQL -----------------
# Cloud SQL is not "in" the VPC like a normal VM. Google runs it in
# its own hidden network and connects it to yours through this PSA
# peering. You only need to create this ONCE per host VPC - if
# another service in the same host VPC already created it, Terraform
# will show an error like "already exists" and you can safely remove
# this resource for that service and re-use the existing one instead.
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "india-tms-dev-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.host_vpc_id
  project       = var.host_project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.host_vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

# ---- 2. Cloud SQL (Postgres 16) ------------------------------------
# Lives in THIS service project, but its private IP is handed out
# from the host VPC via the PSA connection above.
module "db" {
  source                = "../../../modules/database/cloud-sql"
  project_id            = var.project_id
  region                = var.region
  instance_name         = "india-tms-dev-db"
  vpc_id                = var.host_vpc_id
  db_peering_connection = google_service_networking_connection.private_vpc_connection.id
  db_username           = "postgres"
  db_name               = "tms-dev-services-db"
}

/*# ---- 3. GKE cluster (private nodes) --------------------------------
# Runs inside the "tms-dev-private" subnet. Pod and Service IPs come
# from the secondary ranges that india/host-dev already reserved
# on that subnet ("tms-dev-pods" and "tms-dev-services").
module "gke" {
  source = "../../../modules/compute/gke"

  project_id   = var.project_id
  region       = var.region
  cluster_name = "india-tms-dev-gke"

  network_self_link = var.host_vpc_id
  subnet_self_link  = var.host_subnet_self_link

  pods_range_name     = "tms-dev-pods"
  services_range_name = "tms-dev-services"

  # /28 reserved for the GKE control plane - does not overlap any
  # subnet or secondary range (see README "GKE master CIDR plan").
  master_cidr = "10.60.140.0/28"

  # Small + cheap defaults for a dev cluster. Bump these up (and set
  # deletion_protection = true, which is already the module default)
  # before copying this pattern into a staging or prod environment.
  machine_type   = "e2-standard-4"
  min_node_count = 1
  max_node_count = 3

  labels = {
    environment = "dev"
    service     = "tms"
    region      = "india"
    managed_by  = "terraform"
  }
}*/

# ---- 4. Secret Manager ----------------------------------------------
# The Cloud SQL module (step 2) generates a random password and
# returns it as an output. We immediately store it here so the
# plaintext password never appears in any log or state file diff
# after this point.
module "db_secret" {
  source       = "../../../modules/security/secret-manager"
  project_id   = var.project_id
  secret_name  = "india-tms-dev-db-password"
  secret_value = module.db.db_password

  labels = {
    environment = "dev"
    service     = "tms"
    region      = "india"
    managed_by  = "terraform"
  }

  depends_on = [module.db]
}

# ---- 5. Cloud Storage buckets --------------------------------------
# App/infra-support buckets for india/tms-dev. These are plain
# regional buckets (not related to the Terraform state bucket the
# bootstrap step creates) - used by the ALB, CodeBuild, and the TSP
# onboarding-document upload flow.
module "alb_logs_bucket" {
  source = "../../../modules/storage/bucket"

  project_id  = var.project_id
  region      = var.region
  bucket_name = "tms-dev-ff-dev-alb-logs"

  # Access logs pile up fast and are rarely needed past 90 days -
  # auto-delete keeps cost down. Adjust if compliance needs longer.
  lifecycle_age_days = 90

  labels = {
    environment = "dev"
    service     = "tms"
    region      = "india"
    purpose     = "alb-logs"
    managed_by  = "terraform"
  }
}

module "codebuild_bucket" {
  source = "../../../modules/storage/bucket"

  project_id  = var.project_id
  region      = var.region
  bucket_name = "tms-dev-kannan-ff-codebuild-bucket"

  labels = {
    environment = "dev"
    service     = "tms"
    region      = "india"
    purpose     = "codebuild"
    managed_by  = "terraform"
  }
}

module "tsp_onboarding_documents_bucket" {
  source = "../../../modules/storage/bucket"

  project_id  = var.project_id
  region      = var.region
  bucket_name = "tms-dev-mumbai-ffox-tsp-onboarding-documents-v1-poc"

  # Onboarding documents can include sensitive TSP paperwork - keep
  # object versioning on so an accidental overwrite/delete is
  # recoverable. public_access_prevention already defaults to
  # "enforced" in the module, so no public access risk here either.
  versioning_enabled = true

  labels = {
    environment = "dev"
    service     = "tms"
    region      = "india"
    purpose     = "tsp-onboarding-documents"
    managed_by  = "terraform"
  }
}
