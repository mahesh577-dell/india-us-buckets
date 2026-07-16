# Bootstrap for us-analytics-prod (SERVICE project under us-host-prod)
# Creates: APIs + state bucket freightfox-tfstate-us-analytics-prod + SA circleci-tf-us-analytics-prod
# SA also gets networkUser on host (shared VPC access)
# Run: ./run_bootstrap.sh us-analytics-prod

project_id   = "us-analytics-prod-XXXXX" # TODO: actual project ID
env_name     = "us-analytics-prod"
project_type = "analytics"
region       = "us-central1"

host_project_id = "us-host-prod-XXXXX" # TODO: actual host ID
