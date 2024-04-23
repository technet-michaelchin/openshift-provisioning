resource "kubernetes_secret" "logging_loki_s3" {
  metadata {
    name = "logging-loki-s3"
    namespace = "openshift-logging"
  }
  data = {
    access_key_id = var.logging.s3.access_key_id
    access_key_secret = var.logging.s3.secret_access_key
    bucketnames = var.logging.s3.bucketnames
    endpoint = var.logging.s3.endpoint
  }
}

resource "kubernetes_manifest" "loki_stack" {
  manifest = yamldecode(templatefile("${path.module}/manifests/logging/loki-stack.yml.tftpl", {
    storage_class = "nfs-client"
    s3_secret = kubernetes_secret.logging_loki_s3.metadata[0].name
    namespace = "openshift-logging"
  }))
}

resource "kubernetes_manifest" "cluster_logging" {
  manifest = yamldecode(templatefile("${path.module}/manifests/logging/cluster-logging.yml.tftpl", {
    namespace = "openshift-logging"
  }))
}