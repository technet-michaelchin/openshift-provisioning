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
  manifest = {
    apiVersion = "operators.coreos.com/v1"
    kind       = "OperatorGroup"
    metadata = {
      name      = "minio-operator"
      namespace = kubernetes_namespace.minio_operator.metadata[0].name
    }
    spec: {}
  }
}

resource "kubernetes_manifest" "minio_operator" {
  depends_on = [ kubernetes_manifest.minio_operator_group ]
  # count = 0
  manifest = {
    apiVersion = "operators.coreos.com/v1alpha1"
    kind       = "Subscription"
    metadata = {
      name      = "minio-operator"
      namespace = kubernetes_namespace.minio_operator.metadata[0].name
    }
    spec: {
      channel = var.operators.minio.update_channel
      installPlanApproval = "Automatic"
      name = "minio-operator"
      source = "certified-operators"
      sourceNamespace = "openshift-marketplace"
      startingCSV = "minio-operator.v${var.operators.minio.version}"
      config = {
        nodeSelector = {
          "node-role.kubernetes.io/infra": ""
        }
      }
    }
  }
  provisioner "local-exec" {
    when = destroy
    command = <<EOT
    CSV=$(oc get subscription.operators.coreos.com ${self.manifest.metadata.name} -n ${self.manifest.metadata.namespace} -o=jsonpath='{.status.currentCSV}')
    oc delete csv $CSV -n ${self.manifest.metadata.namespace}
    EOT
  }
}

resource "kubernetes_manifest" "minio_operator_console_route" {
  manifest = {
    apiVersion = "route.openshift.io/v1"
    kind       = "Route"
    metadata = {
      name      = "minio-operator-console"
      namespace = kubernetes_namespace.minio_operator.metadata[0].name
    }
    spec: {
      host = "minio-operator-console.lab.technet.local"
      port: {
        targetPort = 9443
      }
      to: {
        kind = "Service"
        name = "console"
      }
      tls: {
        termination = "passthrough"
        insecureEdgeTerminationPolicy = "None"
      }
    }
  }
}