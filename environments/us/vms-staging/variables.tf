variable "project_id" {
  description = "Service project ID (us-vms-staging)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "host_project_id" {
  description = "Host project ID (us-host-staging)"
  type        = string
}

variable "host_vpc_id" {
  description = "Host VPC ID — from us/host-staging output"
  type        = string
}
