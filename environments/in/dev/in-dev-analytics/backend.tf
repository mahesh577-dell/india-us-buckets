terraform {
  backend "gcs" {
    # Bucket lives IN india-analytics-dev project (created by bootstrap)
    bucket = "freightfox-tfstate-india-analytics-dev"
    prefix = "terraform/state"
  }
}
