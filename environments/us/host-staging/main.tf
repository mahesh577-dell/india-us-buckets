# =================================================================
# ENVIRONMENT: us/host-staging   (host project: us-host-staging)
#
# Creates Shared VPC "us-staging-vpc" (us-central1)
# One of 6 shared VPCs (3 India + 3 US)
#
# CIDR: 10.71.0.0/16
# Service projects attached: us-tms-staging, us-vms-staging
# =================================================================

# ---- 1. VPC -----------------------------------------------------
module "vpc" {
  source      = "../../../modules/networking/vpc"
  project_id  = var.host_project_id
  vpc_name    = "us-staging-vpc"
  description = "FreightFox STAGING Shared VPC (US) - tms-staging, vms-staging"
}

# ---- 2. Subnets (us-central1) -----------------------------------
module "subnets" {
  source        = "../../../modules/networking/subnet"
  project_id    = var.host_project_id
  region        = var.region
  vpc_self_link = module.vpc.network_self_link
  flow_sampling = 0.5

  subnets = {
    "tms-staging-public" = {
      cidr                     = "10.71.0.0/22"
      description              = "TMS STAGING Public - LB / Bastion"
      private_ip_google_access = false
    }
    "tms-staging-private" = {
      cidr                     = "10.71.4.0/22"
      description              = "TMS STAGING Private - GKE Nodes"
      private_ip_google_access = true
      secondary_ranges = [
        { range_name = "tms-staging-pods", ip_cidr_range = "10.71.64.0/18" },
        { range_name = "tms-staging-services", ip_cidr_range = "10.71.128.0/22" }
      ]
    }
    "tms-staging-data" = {
      cidr                     = "10.71.8.0/22"
      description              = "TMS STAGING Data - Cloud SQL"
      private_ip_google_access = true
    }
    "vms-staging-public" = {
      cidr                     = "10.71.12.0/22"
      description              = "VMS STAGING Public - LB / Bastion"
      private_ip_google_access = false
    }
    "vms-staging-private" = {
      cidr                     = "10.71.16.0/22"
      description              = "VMS STAGING Private - GKE Nodes"
      private_ip_google_access = true
      secondary_ranges = [
        { range_name = "vms-staging-pods", ip_cidr_range = "10.71.192.0/18" },
        { range_name = "vms-staging-services", ip_cidr_range = "10.71.132.0/22" }
      ]
    }
    "vms-staging-data" = {
      cidr                     = "10.71.20.0/22"
      description              = "VMS STAGING Data - Cloud SQL"
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
