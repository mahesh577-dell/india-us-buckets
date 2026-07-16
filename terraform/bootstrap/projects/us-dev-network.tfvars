# Bootstrap for us-host-dev (HOST project)
# Creates: APIs + state bucket freightfox-tfstate-us-host-dev + SA circleci-tf-us-host-dev
# Run: ./run_bootstrap.sh us-dev-network

project_id   = "us-host-dev-XXXXX" # TODO: actual project ID
env_name     = "us-host-dev"
project_type = "host"
region       = "us-central1"
