variable "project_id" {
  description = "Service project ID (india-tms-prod)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-south1"
}

variable "host_project_id" {
  description = "Host project ID (india-host-prod)"
  type        = string
}

variable "host_vpc_id" {
  description = "Host VPC ID — from in/prod/network/in-prod-network output"
  type        = string
}
