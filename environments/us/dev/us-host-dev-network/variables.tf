variable "host_project_id" {
  description = "Host project ID (us-host-dev)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "service_project_ids" {
  description = "Service projects to attach: us-tms-dev, us-vms-dev, us-analytics-dev"
  type        = list(string)
}
