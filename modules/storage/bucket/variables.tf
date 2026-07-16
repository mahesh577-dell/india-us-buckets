variable "project_id" {
  description = "GCP Project ID the bucket is created in"
  type        = string
}

variable "region" {
  description = "Bucket location - e.g. asia-south1. Can also be a multi-region like ASIA if needed"
  type        = string
}

variable "bucket_name" {
  description = "Globally-unique bucket name - e.g. tms-dev-ff-dev-alb-logs"
  type        = string
}

variable "storage_class" {
  description = "Storage class - STANDARD, NEARLINE, COLDLINE, or ARCHIVE"
  type        = string
  default     = "STANDARD"
}

variable "uniform_bucket_level_access" {
  description = "Disable per-object ACLs in favor of IAM-only access (recommended, leave true unless you have a specific reason not to)"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow 'terraform destroy' to delete this bucket even if it still has objects in it. Keep false for anything holding real data"
  type        = bool
  default     = false
}

variable "public_access_prevention" {
  description = "'enforced' blocks all public access at the project/bucket level regardless of IAM mistakes. Use 'inherited' only if this bucket genuinely needs to be public"
  type        = string
  default     = "enforced"
}

variable "versioning_enabled" {
  description = "Keep old versions of overwritten/deleted objects - turn on for anything you can't afford to lose (documents, uploads). Leave off for logs/scratch/build-artifact buckets"
  type        = bool
  default     = false
}

variable "lifecycle_age_days" {
  description = "Auto-delete objects older than N days. Leave null (default) to keep objects forever - typical for logs (90) or build-artifact buckets (14-30), not for document-storage buckets"
  type        = number
  default     = null
}

variable "labels" {
  description = "Labels to apply to the bucket"
  type        = map(string)
  default     = {}
}
