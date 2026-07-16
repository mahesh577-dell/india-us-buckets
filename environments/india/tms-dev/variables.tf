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
  description = "Host project ID that owns the shared VPC (india/host-dev)"
  type        = string
}

variable "host_vpc_id" {
  description = "Shared VPC self link - copy from the 'vpc_self_link' output of india/host-dev"
  type        = string
}

variable "host_subnet_self_link" {
  description = "Self link of the 'tms-dev-private' subnet - copy from the 'subnet_self_links' output of india/host-dev"
  type        = string
}
