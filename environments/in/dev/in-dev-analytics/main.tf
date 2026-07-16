# =================================================================
# ENVIRONMENT: in/dev/in-dev-analytics   (service project: india-analytics-dev)
# Deploys into Shared VPC of india-host-dev (india-dev-vpc)
#
# PLACEHOLDER — resources to be implemented.
# Uses host subnets: analytics-dev-private 10.60.24.0/22 / analytics-dev-data 10.60.28.0/22
# Analytics uses managed services only (Dataflow/Datastream/BigQuery/PubSub) — NO GKE
# =================================================================

# ---- Cloud Storage bucket -------------------------------------------
# Scratch/test bucket for data science work. Plain regional bucket -
# not related to the Terraform state bucket the bootstrap step creates.
module "data_science_test_bucket" {
  source = "../../../../modules/storage/bucket"

  project_id  = var.project_id
  region      = var.region
  bucket_name = "mumbai-data-science-test"

  versioning_enabled = true

  labels = {
    environment = "dev"
    service     = "analytics"
    region      = "india"
    purpose     = "data-science-test"
    managed_by  = "terraform"
  }
}
