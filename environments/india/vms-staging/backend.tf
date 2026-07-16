terraform {
  backend "gcs" {
    # Bucket lives IN india-vms-staging project (created by bootstrap)
    bucket = "freightfox-tfstate-india-vms-staging"
    prefix = "terraform/state"
  }
}
