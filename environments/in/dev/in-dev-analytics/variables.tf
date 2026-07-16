variable "project_id" {
  description = "Service project ID (india-analytics-dev)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-south1"
}

variable "host_project_id" {
  description = "Host project ID (india-host-dev)"
  type        = string
}

variable "host_vpc_id" {
  description = "Host VPC ID — from in/dev/network/in-dev-network output"
  type        = string
}
