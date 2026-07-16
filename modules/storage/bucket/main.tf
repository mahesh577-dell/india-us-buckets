# ═══════════════════════════════════════════════════════════════
# MODULE: storage/bucket
# AWS EQUIVALENT: S3 bucket
#
# PURPOSE:
# Generic Cloud Storage bucket for app/infra-support use cases:
# → ALB / load balancer access logs
# → CI build artifacts (CodeBuild-equivalent scratch space)
# → Document / file uploads
# → Data pipeline landing zones (email ingestion, data-science scratch, etc.)
#
# NOT used for Terraform state buckets - those are created directly
# by terraform/bootstrap/main.tf, one per project, before this module
# (or any other app infra) exists.
#
# HOW APPS ACCESS:
# Grant the app's service account roles/storage.objectAdmin (or
# .objectViewer for read-only) on the bucket - this module does not
# create IAM bindings itself, so wire those up in the calling
# environment's main.tf, next to the module block.
# ═══════════════════════════════════════════════════════════════

resource "google_storage_bucket" "bucket" {
  project                     = var.project_id
  name                        = var.bucket_name
  location                    = var.region
  storage_class                = var.storage_class
  uniform_bucket_level_access = var.uniform_bucket_level_access
  force_destroy                = var.force_destroy
  public_access_prevention     = var.public_access_prevention

  versioning {
    enabled = var.versioning_enabled
  }

  # Only rendered when lifecycle_age_days is set - leave it null
  # (the default) for buckets that should keep objects forever.
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_age_days != null ? [1] : []
    content {
      condition {
        age = var.lifecycle_age_days
      }
      action {
        type = "Delete"
      }
    }
  }

  labels = var.labels
}
