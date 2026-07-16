# Bootstrap for us-host-staging (HOST project)
# Creates: APIs + state bucket freightfox-tfstate-us-host-staging + SA circleci-tf-us-host-staging
# Run: ./run_bootstrap.sh us-host-staging

project_id   = "us-host-staging-XXXXX" # TODO: actual project ID
env_name     = "us-host-staging"
project_type = "host"
region       = "us-central1"
