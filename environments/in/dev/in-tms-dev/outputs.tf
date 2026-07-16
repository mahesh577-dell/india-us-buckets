output "cloud_sql_instance" {
  value = module.db.instance_name
}

output "cloud_sql_private_ip" {
  value = module.db.private_ip
}

output "db_password_secret" {
  description = "Name of the Secret Manager secret holding the DB password"
  value       = module.db_secret.secret_id
}

/*output "gke_cluster_name" {
  value = module.gke.cluster_name
}*/

/*output "gke_get_credentials_command" {
  description = "Run this to point kubectl at the new cluster"
  value       = module.gke.get_credentials_command
}*/
