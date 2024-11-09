resource "google_compute_network" "this" {
  name                    = "${local.app_name}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "this" {
  name          = "${local.app_name}-subnet"
  region        = local.region
  network       = google_compute_network.this.name
  ip_cidr_range = "10.0.0.0/24"
}
