terraform {
  backend "gcs" {
    # Bucket lives IN us-vms-staging project (created by bootstrap)
    bucket = "freightfox-tfstate-us-vms-staging"
    prefix = "terraform/state"
  }
}
