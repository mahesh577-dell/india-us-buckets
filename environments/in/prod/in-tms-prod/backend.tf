terraform {
  backend "gcs" {
    # Bucket lives IN india-tms-prod project (created by bootstrap)
    bucket = "freightfox-tfstate-india-tms-prod"
    prefix = "terraform/state"
  }
}
