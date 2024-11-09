resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"
}
#
resource "helm_release" "jenkins" {
  namespace        = "jenkins"
  create_namespace = true
  name             = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = "5.6.4"
  max_history      = 5

  values = ["${file("./jenkins.values.yaml")}"]

  set_sensitive {
    name  = "controller.JCasC.configScripts.security"
    value = <<-YAML
      security:
        gitHostKeyVerificationConfiguration:
          sshHostKeyVerificationStrategy: acceptFirstConnectionStrategy
    YAML
  }
}

