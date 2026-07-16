# Bootstrap for india-vms-staging (SERVICE project under india-host-staging)
# Creates: APIs + state bucket freightfox-tfstate-india-vms-staging + SA circleci-tf-india-vms-staging
# SA also gets networkUser on host (shared VPC access)
# Run: ./run_bootstrap.sh india-vms-staging

project_id   = "india-vms-staging-XXXXX" # TODO: actual project ID
env_name     = "india-vms-staging"
project_type = "service"
region       = "asia-south1"

host_project_id = "india-host-staging-XXXXX" # TODO: actual host ID
