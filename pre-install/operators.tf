resource "kubernetes_manifest" "loki_operator" {
  # count = 0
  manifest = yamldecode(templatefile("${path.module}/manifests/subscription.yml.tftpl", {
    namespace = "openshift-operators-redhat"
    channel = var.operators.loki.update_channel
    operator = "loki-operator"
    source = "redhat-operators"
    source_namespace = "openshift-marketplace"
    starting_csv = "loki-operator.v${var.operators.loki.version}"
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

resource "kubernetes_manifest" "logging_operator" {
  # count = 0
  manifest = yamldecode(templatefile("${path.module}/manifests/subscription.yml.tftpl", {
    namespace = "openshift-logging"
    channel = var.operators.logging.update_channel
    operator = "cluster-logging"
    source = "redhat-operators"
    source_namespace = "openshift-marketplace"
    starting_csv = "cluster-logging.v${var.operators.logging.version}"
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

resource "kubernetes_namespace" "minio_operator" {
  metadata {
    name = "minio-operator"
    annotations = {
      "openshift.io/sa.scc.mcs"                 = "s0:c26,c25" 
      "openshift.io/sa.scc.supplemental-groups" = "1000700000/10000" 
      "openshift.io/sa.scc.uid-range"           = "1000700000/10000" 
    }
  }
}

resource "kubernetes_manifest" "minio_operator_group" {
  manifest = yamldecode(templatefile("${path.module}/manifests/operator-group.yml.tftpl", {
    name = "minio-operator-group"
    namespace = kubernetes_namespace.minio_operator.metadata[0].name
  }))
}

resource "kubernetes_manifest" "minio_operator" {
  # count = 0
  depends_on = [ kubernetes_manifest.minio_operator_group ]
  manifest = yamldecode(templatefile("${path.module}/manifests/subscription.yml.tftpl", {
    namespace = kubernetes_namespace.minio_operator.metadata[0].name
    channel = var.operators.minio.update_channel
    operator = "minio-operator"
    source = "certified-operators"
    source_namespace = "openshift-marketplace"
    starting_csv = "minio-operator.v${var.operators.minio.version}"
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

resource "kubernetes_manifest" "kiali_operator" {
  # count = 0
  manifest = yamldecode(templatefile("${path.module}/manifests/subscription.yml.tftpl", {
    namespace = "openshift-operators"
    channel = var.operators.kiali.update_channel
    operator = "kiali-ossm"
    source = "redhat-operators"
    source_namespace = "openshift-marketplace"
    starting_csv = "kiali-operator.v${var.operators.kiali.version}"
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

resource "kubernetes_manifest" "distributed_tracing_operator" {
  manifest = yamldecode(templatefile("${path.module}/manifests/subscription.yml.tftpl", {
    namespace = "openshift-distributed-tracing"
    channel = var.operators.distributed_tracing.update_channel
    operator = "jaeger-product"
    source = "redhat-operators"
    source_namespace = "openshift-marketplace"
    starting_csv = "jaeger-operator.v${var.operators.distributed_tracing.version}"
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

resource "kubernetes_manifest" "service_mesh_operator" {
  depends_on = [
    kubernetes_manifest.distributed_tracing_operator,
    kubernetes_manifest.kiali_operator 
  ]
  manifest = yamldecode(templatefile("${path.module}/manifests/subscription.yml.tftpl", {
    namespace = "openshift-operators"
    channel = var.operators.service_mesh.update_channel
    operator = "servicemeshoperator"
    source = "redhat-operators"
    source_namespace = "openshift-marketplace"
    starting_csv = "servicemeshoperator.v${var.operators.service_mesh.version}"
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
