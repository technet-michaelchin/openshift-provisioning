resource "kubernetes_manifest" "loki_operator" {
  # count = 0
  depends_on = [ kubernetes_manifest.tenants ]
  manifest = yamldecode(templatefile("${path.module}/manifests/subscription.yml.tftpl", {
    namespace = "openshift-operators-redhat"
    channel = var.operators.loki.update_channel
    version = var.operators.loki.version
    operator = "loki-operator"
    source = "redhat-operators"
    source_namespace = "openshift-marketplace"
  }))
  provisioner "local-exec" {
    when = destroy
    command = <<EOT
    CSV=$(oc get subscription.operators.coreos.com ${self.manifest.metadata.name} -n ${self.manifest.metadata.namespace} -o=jsonpath='{.status.currentCSV}')
    oc delete csv $CSV -n ${self.manifest.metadata.namespace}
    EOT
    on_failure = continue
  }
}

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

resource "kubernetes_manifest" "logging_operator" {
  # count = 0
  depends_on = [ kubernetes_manifest.tenants ]
  manifest = yamldecode(templatefile("${path.module}/manifests/subscription.yml.tftpl", {
    namespace = "openshift-logging"
    channel = var.operators.logging.update_channel
    version = var.operators.logging.version
    operator = "cluster-logging"
    source = "redhat-operators"
    source_namespace = "openshift-marketplace"
  }))
  provisioner "local-exec" {
    when = destroy
    command = <<EOT
    CSV=$(oc get subscription.operators.coreos.com ${self.manifest.metadata.name} -n ${self.manifest.metadata.namespace} -o=jsonpath='{.status.currentCSV}')
    oc delete csv $CSV -n ${self.manifest.metadata.namespace}
    EOT
    on_failure = continue
  }
}

resource "kubernetes_manifest" "cluster_logging" {
  manifest = yamldecode(templatefile("${path.module}/manifests/logging/cluster-logging.yml.tftpl", {
    namespace = "openshift-logging"
  }))
}