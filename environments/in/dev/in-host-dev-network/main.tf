# =================================================================        
# ENVIRONMENT: in/dev/in-host-dev-network   (host project: india-host-dev) 
#
# Creates Shared VPC "india-dev-vpc" (asia-south1)
# One of 6 shared VPCs (3 India + 3 US)
#
# CIDR: 10.60.0.0/16
# Service projects attached: india-tms-dev, india-vms-dev, india-analytics-dev
# =================================================================

# ---- 1. VPC -----------------------------------------------------
module "vpc" {
  source      = "../../../../modules/networking/vpc"
  project_id  = var.host_project_id
  vpc_name    = "india-dev-vpc"
  description = "FreightFox DEV Shared VPC (INDIA) - tms-dev, vms-dev, analytics-dev"
}

# ---- 2. Subnets (asia-south1) -----------------------------------
module "subnets" {
  source        = "../../../../modules/networking/subnet"
  project_id    = var.host_project_id
  region        = var.region
  vpc_self_link = module.vpc.network_self_link
  flow_sampling = 0.1

  subnets = {
    "tms-dev-public" = {
      cidr                     = "10.60.0.0/22"
      description              = "TMS DEV Public - LB / Bastion"
      private_ip_google_access = false
    }
    "tms-dev-private" = {
      cidr                     = "10.60.4.0/22"
      description              = "TMS DEV Private - GKE Nodes"
      private_ip_google_access = true
      secondary_ranges = [
        { range_name = "tms-dev-pods", ip_cidr_range = "10.60.64.0/18" },
        { range_name = "tms-dev-services", ip_cidr_range = "10.60.128.0/22" }
      ]
    }
    "tms-dev-data" = {
      cidr                     = "10.60.8.0/22"
      description              = "TMS DEV Data - Cloud SQL"
      private_ip_google_access = true
    }
    "vms-dev-public" = {
      cidr                     = "10.60.12.0/22"
      description              = "VMS DEV Public - LB / Bastion"
      private_ip_google_access = false
    }
    "vms-dev-private" = {
      cidr                     = "10.60.16.0/22"
      description              = "VMS DEV Private - GKE Nodes"
      private_ip_google_access = true
      secondary_ranges = [
        { range_name = "vms-dev-pods", ip_cidr_range = "10.60.192.0/18" },
        { range_name = "vms-dev-services", ip_cidr_range = "10.60.132.0/22" }
      ]
    }
    "vms-dev-data" = {
      cidr                     = "10.60.20.0/22"
      description              = "VMS DEV Data - Cloud SQL"
      private_ip_google_access = true
    }
    "analytics-dev-private" = {
      cidr                     = "10.60.24.0/22"
      description              = "Analytics DEV Private - Dataflow workers / GKE Nodes"
      private_ip_google_access = true
      secondary_ranges = [
        { range_name = "analytics-dev-pods", ip_cidr_range = "10.60.32.0/19" },
        { range_name = "analytics-dev-services", ip_cidr_range = "10.60.136.0/22" }
      ]
    }
    "analytics-dev-data" = {
      cidr                     = "10.60.28.0/22"
      description              = "Analytics DEV Data - BigQuery / Datastream"
      private_ip_google_access = true
    }
  }

  depends_on = [module.vpc]
}

# ---- 3. Shared VPC host + service project attach ------------------
# NOTE: Client ALREADY enabled XPN host + attached service projects
# manually in console. Before first apply, IMPORT the existing
# resources so Terraform manages them without conflict:
#
#   terraform import module.shared_vpc.google_compute_shared_vpc_host_project.host host-dev-network
#   terraform import 'module.shared_vpc.google_compute_shared_vpc_service_project.service["tms-dev-501607"]' host-dev-network/tms-dev-501607
#   terraform import 'module.shared_vpc.google_compute_shared_vpc_service_project.service["vms-dev-501607"]' host-dev-network/vms-dev-501607
#   terraform import 'module.shared_vpc.google_compute_shared_vpc_service_project.service["analytics-dev-501608"]' host-dev-network/analytics-dev-501608
#
# (IAM networkUser bindings will be created fresh by Terraform - no import needed)
module "shared_vpc" {
  source              = "../../../../modules/networking/shared-vpc"
  host_project_id     = var.host_project_id
  service_project_ids = var.service_project_ids

  depends_on = [module.vpc, module.subnets]
}
