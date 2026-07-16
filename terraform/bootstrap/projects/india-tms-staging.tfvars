# Bootstrap for india-tms-staging (SERVICE project under india-host-staging)
# Creates: APIs + state bucket freightfox-tfstate-india-tms-staging + SA circleci-tf-india-tms-staging
# SA also gets networkUser on host (shared VPC access)
# Run: ./run_bootstrap.sh india-tms-staging

project_id   = "india-tms-staging-XXXXX" # TODO: actual project ID
env_name     = "india-tms-staging"
project_type = "service"
region       = "asia-south1"

host_project_id = "india-host-staging-XXXXX" # TODO: actual host ID
