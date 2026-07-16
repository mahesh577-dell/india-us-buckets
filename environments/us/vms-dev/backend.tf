terraform {
  backend "gcs" {
    # Bucket lives IN us-vms-dev project (created by bootstrap)
    bucket = "freightfox-tfstate-us-vms-dev"
    prefix = "terraform/state"
  }
}
