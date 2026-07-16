terraform {
  backend "gcs" {
    # Bucket lives IN us-host-staging project (created by bootstrap)
    bucket = "freightfox-tfstate-us-host-staging"
    prefix = "terraform/state"
  }
}
