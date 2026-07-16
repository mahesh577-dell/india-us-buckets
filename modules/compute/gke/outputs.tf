output "cluster_name" {
  value = google_container_cluster.this.name
}

output "cluster_endpoint" {
  description = "Private IP of the control plane (only reachable from inside the VPC)"
  value       = google_container_cluster.this.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  value     = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive = true
}

output "get_credentials_command" {
  description = "Run this locally (with VPN/bastion access) to connect kubectl to this cluster"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.this.name} --region ${var.region} --project ${var.project_id}"
}
