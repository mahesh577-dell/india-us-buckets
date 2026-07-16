# ---------------------------------------------------------------
# Fill in the 3 values below from the outputs of `us/dev/us-host-dev-network`
# after you have applied that environment:
#   terraform output          (run inside environments/us/dev/us-host-dev-network)
# ---------------------------------------------------------------
project_id      = "REPLACE_WITH_TMS_DEV_PROJECT_ID" # e.g. tms-dev-501607
region          = "us-central1"
host_project_id = "REPLACE_WITH_HOST_DEV_PROJECT_ID" # e.g. us-host-dev-network

host_vpc_id           = "projects/REPLACE_WITH_HOST_DEV_PROJECT_ID/global/networks/us-dev-vpc"
host_subnet_self_link = "projects/REPLACE_WITH_HOST_DEV_PROJECT_ID/regions/us-central1/subnetworks/tms-dev-private"
