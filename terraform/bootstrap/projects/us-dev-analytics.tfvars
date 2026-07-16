# Bootstrap for us-analytics-dev (SERVICE project under us-host-dev)
# Creates: APIs + state bucket freightfox-tfstate-us-analytics-dev + SA circleci-tf-us-analytics-dev
# SA also gets networkUser on host (shared VPC access)
# Run: ./run_bootstrap.sh us-dev-analytics

project_id   = "us-analytics-dev-XXXXX" # TODO: actual project ID
env_name     = "us-analytics-dev"
project_type = "analytics"
region       = "us-central1"

host_project_id = "us-host-dev-XXXXX" # TODO: actual host ID
