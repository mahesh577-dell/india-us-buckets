# Bootstrap for us-tms-staging (SERVICE project under us-host-staging)
# Creates: APIs + state bucket freightfox-tfstate-us-tms-staging + SA circleci-tf-us-tms-staging
# SA also gets networkUser on host (shared VPC access)
# Run: ./run_bootstrap.sh us-tms-staging

project_id   = "us-tms-staging-XXXXX" # TODO: actual project ID
env_name     = "us-tms-staging"
project_type = "service"
region       = "us-central1"

host_project_id = "us-host-staging-XXXXX" # TODO: actual host ID
