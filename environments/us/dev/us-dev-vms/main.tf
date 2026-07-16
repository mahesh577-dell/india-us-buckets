# =================================================================
# ENVIRONMENT: us/dev/us-dev-vms   (service project: us-vms-dev)
#
# Deploys into the Shared VPC owned by us/dev/network/us-dev-network.
# This file does THREE things, in order:
#   1. Opens a private-services connection so Cloud SQL can get a
#      private IP inside the host VPC (no public IP, ever).
#   2. Creates the Cloud SQL (Postgres) instance + a GKE cluster,
#      both living inside the "vms-dev-private" subnet that the
#      host-dev environment already created.
#   3. Stores the generated DB password in Secret Manager so nobody
#      has to email/Slack it around.
#
# NOTHING here creates a VPC or subnet - that already exists,
# created by us/dev/network/us-dev-network. If you're not sure what a subnet
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
  name          = "us-vms-dev-private-ip-alloc"
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
  source                = "../../../../modules/database/cloud-sql"
  project_id            = var.project_id
  region                = var.region
  instance_name         = "us-vms-dev-db"
  vpc_id                = var.host_vpc_id
  db_peering_connection = google_service_networking_connection.private_vpc_connection.id
  db_username           = "postgres"
  db_name               = "vms-dev-services-db"
}

# ---- 3. GKE cluster (private nodes) --------------------------------
# Runs inside the "vms-dev-private" subnet. Pod and Service IPs come
# from the secondary ranges that us/dev/network/us-dev-network already reserved
# on that subnet ("vms-dev-pods" and "vms-dev-services").
module "gke" {
  source = "../../../../modules/compute/gke"

  project_id   = var.project_id
  region       = var.region
  cluster_name = "us-vms-dev-gke"

  network_self_link = var.host_vpc_id
  subnet_self_link  = var.host_subnet_self_link

  pods_range_name     = "vms-dev-pods"
  services_range_name = "vms-dev-services"

  # /28 reserved for the GKE control plane - does not overlap any
  # subnet or secondary range (see README "GKE master CIDR plan").
  master_cidr = "10.70.140.16/28"

  # Small + cheap defaults for a dev cluster. Bump these up (and set
  # deletion_protection = true, which is already the module default)
  # before copying this pattern into a staging or prod environment.
  machine_type   = "e2-standard-4"
  min_node_count = 1
  max_node_count = 3

  labels = {
    environment = "dev"
    service     = "vms"
    region      = "us"
    managed_by  = "terraform"
  }
}

# ---- 4. Secret Manager ----------------------------------------------
# The Cloud SQL module (step 2) generates a random password and
# returns it as an output. We immediately store it here so the
# plaintext password never appears in any log or state file diff
# after this point.
module "db_secret" {
  source       = "../../../../modules/security/secret-manager"
  project_id   = var.project_id
  secret_name  = "us-vms-dev-db-password"
  secret_value = module.db.db_password

  labels = {
    environment = "dev"
    service     = "vms"
    region      = "us"
    managed_by  = "terraform"
  }

  depends_on = [module.db]
}
