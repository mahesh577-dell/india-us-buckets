terraform {
  backend "gcs" {
    # Bucket lives IN india-vms-prod project (created by bootstrap)
    bucket = "freightfox-tfstate-india-vms-prod"
    prefix = "terraform/state"
  }
}
