terraform {
  backend "gcs" {
    # Bucket lives IN us-tms-prod project (created by bootstrap)
    bucket = "freightfox-tfstate-us-tms-prod"
    prefix = "terraform/state"
  }
}
