# Bootstrap for us-vms-dev (SERVICE project under us-host-dev)
# Creates: APIs + state bucket freightfox-tfstate-us-vms-dev + SA circleci-tf-us-vms-dev
# SA also gets networkUser on host (shared VPC access)
# Run: ./run_bootstrap.sh us-vms-dev

project_id   = "us-vms-dev-XXXXX" # TODO: actual project ID
env_name     = "us-vms-dev"
project_type = "service"
region       = "us-central1"

host_project_id = "us-host-dev-XXXXX" # TODO: actual host ID
