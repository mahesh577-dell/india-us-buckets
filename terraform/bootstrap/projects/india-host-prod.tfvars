# Bootstrap for india-host-prod (HOST project)
# Creates: APIs + state bucket freightfox-tfstate-india-host-prod + SA circleci-tf-india-host-prod
# Run: ./run_bootstrap.sh india-host-prod

project_id   = "india-host-prod-XXXXX" # TODO: actual project ID
env_name     = "india-host-prod"
project_type = "host"
region       = "asia-south1"
