# Bootstrap for india-host-staging (HOST project)
# Creates: APIs + state bucket freightfox-tfstate-india-host-staging + SA circleci-tf-india-host-staging
# Run: ./run_bootstrap.sh in-staging-network

project_id   = "india-host-staging-XXXXX" # TODO: actual project ID
env_name     = "india-host-staging"
project_type = "host"
region       = "asia-south1"
