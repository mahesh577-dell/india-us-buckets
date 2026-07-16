# =================================================================
# MODULE: compute/gke
#
# WHAT THIS CREATES
#   A private, regional GKE cluster that runs inside the Shared VPC
#   subnets created by the host-<tier> environment. This module does
#   NOT create any networking — it only consumes:
#     - the private subnet          (var.subnet_self_link)
#     - the "pods" secondary range   (var.pods_range_name)
#     - the "services" secondary range (var.services_range_name)
#
# WHY PRIVATE NODES
#   Nodes get ONLY an internal IP (no public IP). This matches the
#   AWS setup where ECS/EC2 workers sat in private subnets behind a
#   NAT gateway. Engineers reach the cluster control plane through
#   `gcloud container clusters get-credentials` using their normal
#   GCP login (IAM), not a public endpoint.
#
# HOW THIS MAPS TO THE OLD AWS ECS SETUP
#   AWS ECS Service        -> Kubernetes Deployment (not created here)
#   AWS ECS Task           -> Kubernetes Pod
#   AWS EC2 worker node     -> GKE node (in the "private" subnet)
#   AWS Auto Scaling Group  -> GKE node pool (autoscaling min/max below)
# =================================================================

resource "google_container_cluster" "this" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.region # regional cluster = nodes spread across 3 zones automatically

  network    = var.network_self_link
  subnetwork = var.subnet_self_link

  # We manage node pools separately (google_container_node_pool below),
  # so the "default" node pool that GKE creates automatically is removed.
  remove_default_node_pool = true
  initial_node_count       = 1

  # Tells GKE which secondary ranges (created back in the host
  # environment's subnet block) to use for Pod IPs and Service IPs.
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Nodes get only an internal IP. The control plane still gets a
  # Google-managed private endpoint reachable from inside the VPC
  # (and from Cloud Shell / VPN once that is set up).
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false # set true later once VPN/bastion access is ready
    master_ipv4_cidr_block  = var.master_cidr
  }

  # Standard security/ops add-ons switched on by default.
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = var.release_channel
  }

  deletion_protection = var.deletion_protection
}

resource "google_container_node_pool" "primary" {
  name     = "${var.cluster_name}-primary"
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.this.name

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb

    # No public IP on nodes - matches "private_nodes" above.
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = var.labels

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
