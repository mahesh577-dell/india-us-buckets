variable "project_id" {
  description = "Service project ID (india-tms-dev), e.g. tms-dev-501607"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-south1"
}

variable "host_project_id" {
  description = "Host project ID that owns the shared VPC (in/dev/in-host-dev-network)"
  type        = string
}

variable "host_vpc_id" {
  description = "Shared VPC self link - copy from the 'vpc_self_link' output of in/dev/in-host-dev-network"
  type        = string
}

variable "host_subnet_self_link" {
  description = "Self link of the 'tms-dev-private' subnet - copy from the 'subnet_self_links' output of in/dev/in-host-dev-network"
  type        = string
}
