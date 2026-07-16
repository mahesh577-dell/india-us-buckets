variable "host_project_id" {
  description = "Host project ID (india-host-staging)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-south1"
}

variable "service_project_ids" {
  description = "Service projects to attach: india-tms-staging, india-vms-staging"
  type        = list(string)
}
