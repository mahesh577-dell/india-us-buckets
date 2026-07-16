terraform {
  backend "gcs" {
    # Bucket lives IN us-analytics-prod project (created by bootstrap)
    bucket = "freightfox-tfstate-us-analytics-prod"
    prefix = "terraform/state"
  }
}
