# Values below came from the "in-*" projects the client already  
# created (see host_project_id / host_vpc_id / host_subnet_self_link
# in the output of `terraform apply` inside environments/in/dev/network/in-dev-network).
project_id      = "tms-dev-501607" # in-tms-dev
region          = "asia-south1"
host_project_id = "host-dev-network" # in-host-dev-network

host_vpc_id           = "projects/host-dev-network/global/networks/india-dev-vpc"
host_subnet_self_link = "projects/host-dev-network/regions/asia-south1/subnetworks/tms-dev-private"
