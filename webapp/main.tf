resource "google_storage_bucket" "webapp" {
  location                    = "EU"
  name                        = "${local.app_name}-webpage"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "webapp" {
  bucket       = google_storage_bucket.webapp.name
  name         = "index.html"
  content      = file("./index.html")
  content_type = "text/html"
}

locals {
  namespace       = "default"
  service_account = "test-webapp"
}

resource "google_storage_bucket_iam_binding" "webapp" {
  bucket  = google_storage_bucket.webapp.id
  members = ["principal://iam.googleapis.com/projects/${data.google_project.gnutive.number}/locations/global/workloadIdentityPools/${local.project}.svc.id.goog/subject/ns/${local.namespace}/sa/${local.service_account}"]
  role    = "roles/storage.objectViewer"
}

resource "helm_release" "webapp" {
  name       = "webapp"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"

  values = [file("./nginx.yaml")]

  set {
    name  = "serviceAccount.name"
    value = local.service_account
  }

  set {
    name = "extraVolumeMounts"
    value = yamlencode([{
      name      = "webapp-bucket-efemeral"
      mountPath = "/app"
      readOnly  = true
    }])
  }

  set {
    name = "extraVolumes"
    value = yamlencode([{
      name = "webapp-bucket-efemeral"
      csi = {
        driver   = "gcsfuse.csi.storage.gke.io"
        readOnly = true
        volumeAttributes = {
          bucketName             = google_storage_bucket.webapp.name
          mountOptions           = "implicit-dirs"
          gcsfuseLoggingSeverity = "warning"
    } } }])
  }

  depends_on = [google_storage_bucket_iam_binding.webapp]
}
