terraform {
  backend "gcs" {
    # Bucket lives IN india-vms-dev project (created by bootstrap)
    bucket = "freightfox-tfstate-india-vms-dev"
    prefix = "terraform/state"
  }
}
