# Bootstrap for us-vms-prod (SERVICE project under us-host-prod)
# Creates: APIs + state bucket freightfox-tfstate-us-vms-prod + SA circleci-tf-us-vms-prod
# SA also gets networkUser on host (shared VPC access)
# Run: ./run_bootstrap.sh us-prod-vms

project_id   = "us-vms-prod-XXXXX" # TODO: actual project ID
env_name     = "us-vms-prod"
project_type = "service"
region       = "us-central1"

host_project_id = "us-host-prod-XXXXX" # TODO: actual host ID
