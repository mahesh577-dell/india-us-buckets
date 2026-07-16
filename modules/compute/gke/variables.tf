variable "project_id" {
  description = "Service project ID that will own the GKE cluster (e.g. tms-dev-501607)"
  type        = string
}

variable "region" {
  description = "GCP region, e.g. asia-south1"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster, e.g. in-tms-dev-gke"
  type        = string
}

variable "network_self_link" {
  description = "Self link of the HOST project's shared VPC (from host-<tier> environment output vpc_self_link)"
  type        = string
}

variable "subnet_self_link" {
  description = "Self link of this service's private subnet (from host-<tier> output subnet_self_links[\"tms-dev-private\"] or similar)"
  type        = string
}

variable "pods_range_name" {
  description = "Name of the secondary range for pods, e.g. tms-dev-pods (must already exist on the subnet)"
  type        = string
}

variable "services_range_name" {
  description = "Name of the secondary range for services, e.g. tms-dev-services (must already exist on the subnet)"
  type        = string
}

variable "master_cidr" {
  description = "A /28 CIDR for the GKE control plane, must not overlap any subnet. See README for the reserved /28 per environment."
  type        = string
}

variable "machine_type" {
  description = "Node machine type"
  type        = string
  default     = "e2-standard-4"
}

variable "disk_size_gb" {
  description = "Boot disk size per node"
  type        = number
  default     = 100
}

variable "min_node_count" {
  description = "Minimum nodes per zone (regional cluster = this x 3 zones minimum)"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum nodes per zone (regional cluster = this x 3 zones maximum)"
  type        = number
  default     = 3
}

variable "release_channel" {
  description = "GKE release channel: RAPID, REGULAR, or STABLE"
  type        = string
  default     = "REGULAR"
}

variable "deletion_protection" {
  description = "Prevent accidental terraform destroy of this cluster (set false only for throwaway dev testing)"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels applied to every node"
  type        = map(string)
  default     = {}
}
