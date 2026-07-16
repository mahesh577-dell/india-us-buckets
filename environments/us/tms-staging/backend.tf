terraform {
  backend "gcs" {
    # Bucket lives IN us-tms-staging project (created by bootstrap)
    bucket = "freightfox-tfstate-us-tms-staging"
    prefix = "terraform/state"
  }
}
