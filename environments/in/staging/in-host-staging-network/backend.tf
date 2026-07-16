terraform {
  backend "gcs" {
    # Bucket lives IN india-host-staging project (created by bootstrap)
    bucket = "freightfox-tfstate-india-host-staging"
    prefix = "terraform/state"
  }
}
