terraform {
  backend "gcs" {
    # Bucket lives IN india-tms-dev project (created by bootstrap)
    bucket = "freightfox-tfstate-india-tms-dev"
    prefix = "terraform/state"
  }
}
