variable "host_project_id" {
  description = "Host project ID (india-host-dev)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-south1"
}

variable "service_project_ids" {
  description = "Service projects to attach: india-tms-dev, india-vms-dev, india-analytics-dev"
  type        = list(string)
}
