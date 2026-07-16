# =================================================================   
# ENVIRONMENT: us/host-prod   (host project: us-host-prod)
#
# Creates Shared VPC "us-prod-vpc" (us-central1)
# One of 6 shared VPCs (3 India + 3 US)
#
# CIDR: 10.72.0.0/16
# Service projects attached: us-tms-prod, us-vms-prod, us-analytics-prod
# =================================================================

# ---- 1. VPC -----------------------------------------------------
module "vpc" {
  source      = "../../../modules/networking/vpc"
  project_id  = var.host_project_id
  vpc_name    = "us-prod-vpc"
  description = "FreightFox PROD Shared VPC (US) - tms-prod, vms-prod, analytics-prod"
}

# ---- 2. Subnets (us-central1) -----------------------------------
module "subnets" {
  source        = "../../../modules/networking/subnet"
  project_id    = var.host_project_id
  region        = var.region
  vpc_self_link = module.vpc.network_self_link
  flow_sampling = 1.0

  subnets = {
    "tms-prod-public" = {
      cidr                     = "10.72.0.0/22"
      description              = "TMS PROD Public - LB / Bastion"
      private_ip_google_access = false
    }
    "tms-prod-private" = {
      cidr                     = "10.72.4.0/22"
      description              = "TMS PROD Private - GKE Nodes"
      private_ip_google_access = true
      secondary_ranges = [
        { range_name = "tms-prod-pods", ip_cidr_range = "10.72.64.0/18" },
        { range_name = "tms-prod-services", ip_cidr_range = "10.72.128.0/22" }
      ]
    }
    "tms-prod-data" = {
      cidr                     = "10.72.8.0/22"
      description              = "TMS PROD Data - Cloud SQL"
      private_ip_google_access = true
    }
    "vms-prod-public" = {
      cidr                     = "10.72.12.0/22"
      description              = "VMS PROD Public - LB / Bastion"
      private_ip_google_access = false
    }
    "vms-prod-private" = {
      cidr                     = "10.72.16.0/22"
      description              = "VMS PROD Private - GKE Nodes"
      private_ip_google_access = true
      secondary_ranges = [
        { range_name = "vms-prod-pods", ip_cidr_range = "10.72.192.0/18" },
        { range_name = "vms-prod-services", ip_cidr_range = "10.72.132.0/22" }
      ]
    }
    "vms-prod-data" = {
      cidr                     = "10.72.20.0/22"
      description              = "VMS PROD Data - Cloud SQL"
      private_ip_google_access = true
    }
    "analytics-prod-private" = {
      cidr                     = "10.72.24.0/22"
      description              = "Analytics PROD Private - Dataflow workers / GKE Nodes"
      private_ip_google_access = true
      secondary_ranges = [
        { range_name = "analytics-prod-pods", ip_cidr_range = "10.72.32.0/19" },
        { range_name = "analytics-prod-services", ip_cidr_range = "10.72.136.0/22" }
      ]
    }
    "analytics-prod-data" = {
      cidr                     = "10.72.28.0/22"
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
