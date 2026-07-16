variable "project_id" {
  description = "Service project ID (us-tms-prod)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "host_project_id" {
  description = "Host project ID (us-host-prod)"
  type        = string
}

variable "host_vpc_id" {
  description = "Host VPC ID — from us/prod/network/us-prod-network output"
  type        = string
}
