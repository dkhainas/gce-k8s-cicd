locals {
  region   = "europe-southwest1"
  project  = "gnutive"
  app_name = "test-task"
}

terraform {
  backend "gcs" {
    bucket = "test-task-terraform"
    prefix = "webapp"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
  }
}

data "google_container_cluster" "this" {
  name = "${local.app_name}-cluster"
}

provider "google" {
  project = local.project
  region  = local.region
}

data "google_client_config" "current" {}

data "google_project" "gnutive" {
  project_id = local.project
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.this.endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.this.master_auth.0.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gke-gcloud-auth-plugin"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.google_container_cluster.this.endpoint
    token                  = data.google_client_config.current.access_token
    client_certificate     = base64decode(data.google_container_cluster.this.master_auth.0.client_certificate)
    client_key             = base64decode(data.google_container_cluster.this.master_auth.0.client_key)
    cluster_ca_certificate = base64decode(data.google_container_cluster.this.master_auth.0.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
    }
  }
}
