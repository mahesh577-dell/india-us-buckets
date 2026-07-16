terraform {
  backend "gcs" {
    # Bucket lives IN india-host-prod project (created by bootstrap)
    bucket = "freightfox-tfstate-india-host-prod"
    prefix = "terraform/state"
  }
}
