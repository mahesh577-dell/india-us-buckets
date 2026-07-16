terraform {
  backend "gcs" {
    # Bucket lives IN india-analytics-prod project (created by bootstrap)
    bucket = "freightfox-tfstate-india-analytics-prod"
    prefix = "terraform/state"
  }
}
