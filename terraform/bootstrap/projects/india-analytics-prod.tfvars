# Bootstrap for india-analytics-prod (SERVICE project under india-host-prod)
# Creates: APIs + state bucket freightfox-tfstate-india-analytics-prod + SA circleci-tf-india-analytics-prod
# SA also gets networkUser on host (shared VPC access)
# Run: ./run_bootstrap.sh india-analytics-prod

project_id   = "india-analytics-prod-XXXXX" # TODO: actual project ID
env_name     = "india-analytics-prod"
project_type = "analytics"
region       = "asia-south1"

host_project_id = "india-host-prod-XXXXX" # TODO: actual host ID
