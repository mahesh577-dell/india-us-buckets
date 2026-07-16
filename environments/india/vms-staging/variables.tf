variable "project_id" {
  description = "Service project ID (india-vms-staging)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-south1"
}

variable "host_project_id" {
  description = "Host project ID (india-host-staging)"
  type        = string
}

variable "host_vpc_id" {
  description = "Host VPC ID — from india/host-staging output"
  type        = string
}
