terraform {
  backend "gcs" {
    # Bucket lives IN india-tms-staging project (created by bootstrap)
    bucket = "freightfox-tfstate-india-tms-staging"
    prefix = "terraform/state"
  }
}
