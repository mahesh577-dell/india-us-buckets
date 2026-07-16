# Bootstrap for india-vms-prod (SERVICE project under india-host-prod)
# Creates: APIs + state bucket freightfox-tfstate-india-vms-prod + SA circleci-tf-india-vms-prod
# SA also gets networkUser on host (shared VPC access)
# Run: ./run_bootstrap.sh in-prod-vms

project_id   = "india-vms-prod-XXXXX" # TODO: actual project ID
env_name     = "india-vms-prod"
project_type = "service"
region       = "asia-south1"

host_project_id = "india-host-prod-XXXXX" # TODO: actual host ID
