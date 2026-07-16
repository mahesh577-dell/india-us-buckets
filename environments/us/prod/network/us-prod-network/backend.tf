terraform {
  backend "gcs" {
    # Bucket lives IN us-host-prod project (created by bootstrap)
    bucket = "freightfox-tfstate-us-host-prod"
    prefix = "terraform/state"
  }
}
