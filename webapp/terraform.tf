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
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
  }
}

provider "google" {
  project = local.project
  region  = local.region
}

data "google_project" "gnutive" {
  project_id = local.project
}
