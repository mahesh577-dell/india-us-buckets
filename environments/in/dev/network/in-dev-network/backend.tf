terraform {
  backend "gcs" {
    # Bucket lives IN india-host-dev project (created by bootstrap)
    bucket = "freightfox-tfstate-india-host-dev"
    prefix = "terraform/state"
  }
}
