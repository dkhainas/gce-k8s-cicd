resource "google_service_account" "k8s" {
  account_id   = "k8s-test"
  display_name = "k8s-test"
  project      = local.project
}

resource "google_storage_bucket" "terraform" {
  location                    = "EU"
  name                        = "${local.app_name}-terraform"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "terraform" {
  bucket = google_storage_bucket.terraform.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.k8s.email}"
}

resource "google_artifact_registry_repository_iam_member" "repos" {
  repository = google_artifact_registry_repository.jenkins_agent.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.k8s.email}"
}

data "google_container_engine_versions" "gke_version" {
  location       = local.region
  version_prefix = "1.30."
}

data "google_project" "gnutive" {
  project_id = local.project
}

resource "google_container_cluster" "this" {
  name               = "${local.app_name}-cluster"
  location           = local.region
  initial_node_count = 1

  node_config {
    service_account = google_service_account.k8s.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    machine_type = "e2-standard-4"
  }
  network             = google_compute_network.this.name
  subnetwork          = google_compute_subnetwork.this.name
  deletion_protection = false
  addons_config {
    http_load_balancing {
      disabled = false
    }
    gcs_fuse_csi_driver_config {
      enabled = true
    }
  }

  workload_identity_config {
    workload_pool = "${data.google_project.gnutive.project_id}.svc.id.goog"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
}


