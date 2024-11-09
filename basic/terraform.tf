terraform {
  backend "gcs" {
    bucket = "test-task-terraform"
    prefix = "basic"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.10.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
  }

  required_version = ">= 1.9"
}

provider "google" {
  project = local.project
  region  = local.region
}

locals {
  region   = "europe-southwest1"
  project  = "gnutive"
  app_name = "test-task"
}

data "google_client_config" "current" {}

provider "helm" {
  kubernetes {
    host                   = google_container_cluster.this.endpoint
    token                  = data.google_client_config.current.access_token
    client_certificate     = base64decode(google_container_cluster.this.master_auth.0.client_certificate)
    client_key             = base64decode(google_container_cluster.this.master_auth.0.client_key)
    cluster_ca_certificate = base64decode(google_container_cluster.this.master_auth.0.cluster_ca_certificate)
  }
}
