locals {
  namespace                  = "jenkins"
  agent_service_account      = "cicd-agent"
  controller_service_account = "cicd-controller"
}

resource "google_artifact_registry_repository" "jenkins_agent" {
  location      = local.region
  repository_id = "jenkins-gce-terraform-agent"
  description   = "Agent Image for deploying to K8S with Terraform"
  format        = "DOCKER"
}

resource "helm_release" "jenkins" {
  namespace        = local.namespace
  create_namespace = true
  name             = "cicd"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = "5.6.4"
  max_history      = 5

  values = ["${file("./jenkins.values.yaml")}"]

  set {
    name  = "jnlpRegistry"
    value = "${local.region}-docker.pkg.dev"
  }

  set {
    name  = "image.repository"
    value = "${local.project}/${google_artifact_registry_repository.jenkins_agent.name}/agent"
  }

  set {
    name  = "serviceAccount.name"
    value = local.controller_service_account
  }

  set {
    name  = "serviceAccountAgent.create"
    value = true
  }

  set {
    name  = "serviceAccountAgent.name"
    value = local.agent_service_account
  }

  set_sensitive {
    name  = "controller.JCasC.configScripts.security"
    value = <<-YAML
      security:
        gitHostKeyVerificationConfiguration:
          sshHostKeyVerificationStrategy: acceptFirstConnectionStrategy
    YAML
  }
}

resource "google_project_iam_member" "container" {
  project = local.project
  role    = "roles/container.developer"
  member  = "principal://iam.googleapis.com/projects/${data.google_project.gnutive.number}/locations/global/workloadIdentityPools/${local.project}.svc.id.goog/subject/ns/${local.namespace}/sa/${local.agent_service_account}"
}

resource "google_project_iam_member" "compute" {
  project = local.project
  role    = "roles/compute.viewer"
  member  = "principal://iam.googleapis.com/projects/${data.google_project.gnutive.number}/locations/global/workloadIdentityPools/${local.project}.svc.id.goog/subject/ns/${local.namespace}/sa/${local.agent_service_account}"
}

resource "google_project_iam_member" "storage" {
  project = local.project
  role    = "roles/storage.admin"
  member  = "principal://iam.googleapis.com/projects/${data.google_project.gnutive.number}/locations/global/workloadIdentityPools/${local.project}.svc.id.goog/subject/ns/${local.namespace}/sa/${local.agent_service_account}"
}
