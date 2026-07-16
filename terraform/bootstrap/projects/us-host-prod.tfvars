# Bootstrap for us-host-prod (HOST project)
# Creates: APIs + state bucket freightfox-tfstate-us-host-prod + SA circleci-tf-us-host-prod
# Run: ./run_bootstrap.sh us-host-prod

project_id   = "us-host-prod-XXXXX" # TODO: actual project ID
env_name     = "us-host-prod"
project_type = "host"
region       = "us-central1"
