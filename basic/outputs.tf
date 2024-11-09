output "region" {
  value = local.region
}

output "k8s_cluster_name" {
  value = google_container_cluster.this.name
}

output "k8s_host" {
  value = google_container_cluster.this.endpoint
}
