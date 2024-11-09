resource "google_service_account" "k8s" {
  account_id   = "k8s-test"
  display_name = "k8s-test"
  project      = local.project
}

data "google_container_engine_versions" "gke_version" {
  location       = local.region
  version_prefix = "1.30."
}

resource "google_container_cluster" "this" {
  name               = "${local.app_name}-cluster"
  location           = local.region
  initial_node_count = 1

  node_config {
    service_account = google_service_account.k8s.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  network             = google_compute_network.this.name
  subnetwork          = google_compute_subnetwork.this.name
  deletion_protection = false
  addons_config {
    http_load_balancing {
      disabled = false
    }
  }
}
