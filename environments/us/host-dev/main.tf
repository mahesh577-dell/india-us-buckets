# ================================================================= 
# ENVIRONMENT: us/host-dev   (host project: us-host-dev)
#
# Creates Shared VPC "us-dev-vpc" (us-central1)
# One of 6 shared VPCs (3 India + 3 US)
#
# CIDR: 10.70.0.0/16
# Service projects attached: us-tms-dev, us-vms-dev, us-analytics-dev
# =================================================================

# ---- 1. VPC -----------------------------------------------------
module "vpc" {
  source      = "../../../modules/networking/vpc"
  project_id  = var.host_project_id
  vpc_name    = "us-dev-vpc"
  description = "FreightFox DEV Shared VPC (US) - tms-dev, vms-dev, analytics-dev"
}

# ---- 2. Subnets (us-central1) -----------------------------------
module "subnets" {
  source        = "../../../modules/networking/subnet"
  project_id    = var.host_project_id
  region        = var.region
  vpc_self_link = module.vpc.network_self_link
  flow_sampling = 0.1

  subnets = {
    "tms-dev-public" = {
      cidr                     = "10.70.0.0/22"
      description              = "TMS DEV Public - LB / Bastion"
      private_ip_google_access = false
    }
    "tms-dev-private" = {
      cidr                     = "10.70.4.0/22"
      description              = "TMS DEV Private - GKE Nodes"
      private_ip_google_access = true
      secondary_ranges = [
        { range_name = "tms-dev-pods", ip_cidr_range = "10.70.64.0/18" },
        { range_name = "tms-dev-services", ip_cidr_range = "10.70.128.0/22" }
      ]
    }
    "tms-dev-data" = {
      cidr                     = "10.70.8.0/22"
      description              = "TMS DEV Data - Cloud SQL"
      private_ip_google_access = true
    }
    "vms-dev-public" = {
      cidr                     = "10.70.12.0/22"
      description              = "VMS DEV Public - LB / Bastion"
      private_ip_google_access = false
    }
    "vms-dev-private" = {
      cidr                     = "10.70.16.0/22"
      description              = "VMS DEV Private - GKE Nodes"
      private_ip_google_access = true
      secondary_ranges = [
        { range_name = "vms-dev-pods", ip_cidr_range = "10.70.192.0/18" },
        { range_name = "vms-dev-services", ip_cidr_range = "10.70.132.0/22" }
      ]
    }
    "vms-dev-data" = {
      cidr                     = "10.70.20.0/22"
      description              = "VMS DEV Data - Cloud SQL"
      private_ip_google_access = true
    }
    "analytics-dev-private" = {
      cidr                     = "10.70.24.0/22"
      description              = "Analytics DEV Private - Dataflow workers / GKE Nodes"
      private_ip_google_access = true
      secondary_ranges = [
        { range_name = "analytics-dev-pods", ip_cidr_range = "10.70.32.0/19" },
        { range_name = "analytics-dev-services", ip_cidr_range = "10.70.136.0/22" }
      ]
    }
    "analytics-dev-data" = {
      cidr                     = "10.70.28.0/22"
      description              = "Analytics DEV Data - BigQuery / Datastream"
      private_ip_google_access = true
    }
  }

  depends_on = [module.vpc]
}

# ---- 3. Shared VPC host + service project attach ------------------
module "shared_vpc" {
  source              = "../../../modules/networking/shared-vpc"
  host_project_id     = var.host_project_id
  service_project_ids = var.service_project_ids

  depends_on = [module.vpc, module.subnets]
}
