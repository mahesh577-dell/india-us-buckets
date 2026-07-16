terraform {
  backend "gcs" {
    # Bucket lives IN us-host-dev project (created by bootstrap)
    bucket = "freightfox-tfstate-us-host-dev"
    prefix = "terraform/state"
  }
}
