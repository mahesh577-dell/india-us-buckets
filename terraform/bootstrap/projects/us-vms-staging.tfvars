# Bootstrap for us-vms-staging (SERVICE project under us-host-staging)
# Creates: APIs + state bucket freightfox-tfstate-us-vms-staging + SA circleci-tf-us-vms-staging
# SA also gets networkUser on host (shared VPC access)
# Run: ./run_bootstrap.sh us-vms-staging

project_id   = "us-vms-staging-XXXXX" # TODO: actual project ID
env_name     = "us-vms-staging"
project_type = "service"
region       = "us-central1"

host_project_id = "us-host-staging-XXXXX" # TODO: actual host ID
