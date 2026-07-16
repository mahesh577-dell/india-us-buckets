# Bootstrap for india-tms-prod (SERVICE project under india-host-prod)
# Creates: APIs + state bucket freightfox-tfstate-india-tms-prod + SA circleci-tf-india-tms-prod
# SA also gets networkUser on host (shared VPC access)
# Run: ./run_bootstrap.sh india-tms-prod

project_id   = "india-tms-prod-XXXXX" # TODO: actual project ID
env_name     = "india-tms-prod"
project_type = "service"
region       = "asia-south1"

host_project_id = "india-host-prod-XXXXX" # TODO: actual host ID
