# =================================================================   
# ENVIRONMENT: india/host-prod   (host project: india-host-prod)
#
# Creates Shared VPC "india-prod-vpc" (asia-south1)
# One of 6 shared VPCs (3 India + 3 US)
#
# CIDR: 10.62.0.0/16
# Service projects attached: india-tms-prod, india-vms-prod, india-analytics-prod
# =================================================================

# ---- 1. VPC -----------------------------------------------------
module "vpc" {
  source      = "../../../modules/networking/vpc"
  project_id  = var.host_project_id
  vpc_name    = "india-prod-vpc"
  description = "FreightFox PROD Shared VPC (INDIA) - tms-prod, vms-prod, analytics-prod"
}

# ---- 2. Subnets (asia-south1) -----------------------------------
module "subnets" {
  source        = "../../../modules/networking/subnet"
  project_id    = var.host_project_id
  region        = var.region
  vpc_self_link = module.vpc.network_self_link
  flow_sampling = 1.0

  subnets = {
    "tms-prod-public" = {
      cidr                     = "10.62.0.0/22"
      description              = "TMS PROD Public - LB / Bastion"
      private_ip_google_access = false
    }
    "tms-prod-private" = {
      cidr                     = "10.62.4.0/22"
      description              = "TMS PROD Private - GKE Nodes"
      private_ip_google_access = true
      secondary_ranges = [
        { range_name = "tms-prod-pods", ip_cidr_range = "10.62.64.0/18" },
        { range_name = "tms-prod-services", ip_cidr_range = "10.62.128.0/22" }
      ]
    }
    "tms-prod-data" = {
      cidr                     = "10.62.8.0/22"
      description              = "TMS PROD Data - Cloud SQL"
      private_ip_google_access = true
    }
    "vms-prod-public" = {
      cidr                     = "10.62.12.0/22"
      description              = "VMS PROD Public - LB / Bastion"
      private_ip_google_access = false
    }
    "vms-prod-private" = {
      cidr                     = "10.62.16.0/22"
      description              = "VMS PROD Private - GKE Nodes"
      private_ip_google_access = true
      secondary_ranges = [
        { range_name = "vms-prod-pods", ip_cidr_range = "10.62.192.0/18" },
        { range_name = "vms-prod-services", ip_cidr_range = "10.62.132.0/22" }
      ]
    }
    "vms-prod-data" = {
      cidr                     = "10.62.20.0/22"
      description              = "VMS PROD Data - Cloud SQL"
      private_ip_google_access = true
    }
    "analytics-prod-private" = {
      cidr                     = "10.62.24.0/22"
      description              = "Analytics PROD Private - Dataflow workers / GKE Nodes"
      private_ip_google_access = true
      secondary_ranges = [
        { range_name = "analytics-prod-pods", ip_cidr_range = "10.62.32.0/19" },
        { range_name = "analytics-prod-services", ip_cidr_range = "10.62.136.0/22" }
      ]
    }
    "analytics-prod-data" = {
      cidr                     = "10.62.28.0/22"
      description              = "Analytics PROD Data - BigQuery / Datastream"
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
