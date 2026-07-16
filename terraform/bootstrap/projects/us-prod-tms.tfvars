# Bootstrap for us-tms-prod (SERVICE project under us-host-prod)
# Creates: APIs + state bucket freightfox-tfstate-us-tms-prod + SA circleci-tf-us-tms-prod
# SA also gets networkUser on host (shared VPC access)
# Run: ./run_bootstrap.sh us-prod-tms

project_id   = "us-tms-prod-XXXXX" # TODO: actual project ID
env_name     = "us-tms-prod"
project_type = "service"
region       = "us-central1"

host_project_id = "us-host-prod-XXXXX" # TODO: actual host ID
