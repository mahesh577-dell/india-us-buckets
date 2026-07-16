terraform {
  backend "gcs" {
    # Bucket lives IN us-analytics-dev project (created by bootstrap)
    bucket = "freightfox-tfstate-us-analytics-dev"
    prefix = "terraform/state"
  }
}
