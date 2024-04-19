resource "kubernetes_manifest" "kiali_operator" {
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

# resource "kubernetes_manifest" "elasticsearch_operator" {
#   manifest = yamldecode(templatefile("${path.module}/manifests/subscription.yml.tftpl", {
#     namespace = "openshift-operators-redhat"
#     channel = var.operators.elasticsearch.update_channel
#     version = var.operators.elasticsearch.version
#     operator = "elasticsearch-operator"
#     source = "redhat-operators"
#     source_namespace = "openshift-marketplace"
#   }))
#   provisioner "local-exec" {
#     when = destroy
#     command = <<EOT
#     CSV=$(oc get subscription.operators.coreos.com ${self.manifest.metadata.name} -n ${self.manifest.metadata.namespace} -o=jsonpath='{.status.currentCSV}')
#     oc delete csv $CSV -n ${self.manifest.metadata.namespace}
#     EOT
#     on_failure = continue
#   }
# }

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    annotations = {
      "openshift.io/sa.scc.mcs"                 = "s0:c28,c12" 
      "openshift.io/sa.scc.supplemental-groups" = "1000780000/10000" 
      "openshift.io/sa.scc.uid-range"           = "1000780000/10000" 
    }
    labels = {
      "maistra.io/member-of" = "istio-system"
      "kiali.io/member-of"   = "istio-system"
    }
  }
}

resource "kubernetes_manifest" "control_plane" {
  manifest = yamldecode(templatefile("${path.module}/manifests/service-mesh/control-plane.yml.tftpl", {
    namespace = kubernetes_namespace.istio_system.metadata[0].name
  }))
}
