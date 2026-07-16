# Bootstrap for us-tms-dev (SERVICE project under us-host-dev)
# Creates: APIs + state bucket freightfox-tfstate-us-tms-dev + SA circleci-tf-us-tms-dev
# SA also gets networkUser on host (shared VPC access)
# Run: ./run_bootstrap.sh us-tms-dev

project_id   = "us-tms-dev-XXXXX" # TODO: actual project ID
env_name     = "us-tms-dev"
project_type = "service"
region       = "us-central1"

host_project_id = "us-host-dev-XXXXX" # TODO: actual host ID
