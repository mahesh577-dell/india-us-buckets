terraform {
  backend "gcs" {
    # Bucket lives IN us-vms-prod project (created by bootstrap)
    bucket = "freightfox-tfstate-us-vms-prod"
    prefix = "terraform/state"
  }
}
