variable "host_project_id" {
  description = "Host project ID (us-host-prod)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "service_project_ids" {
  description = "Service projects to attach: us-tms-prod, us-vms-prod, us-analytics-prod"
  type        = list(string)
}
