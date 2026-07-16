terraform {
  backend "gcs" {
    # Bucket lives IN us-tms-dev project (created by bootstrap)
    bucket = "freightfox-tfstate-us-tms-dev"
    prefix = "terraform/state"
  }
}
