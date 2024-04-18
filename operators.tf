# resource "kubernetes_manifest" "kiali_operator" {
#   # count = 0
#   manifest = {
#     apiVersion = "operators.coreos.com/v1alpha1"
#     kind       = "Subscription"
#     metadata = {
#       name      = "kiali-ossm"
#       namespace = "openshift-operators"
#     }
#     spec: {
#       channel = var.operators.kiali.update_channel
#       installPlanApproval = "Automatic"
#       name = "kiali-ossm"
#       source = "redhat-operators"
#       sourceNamespace = "openshift-marketplace"
#       startingCSV = "kiali-operator.v${var.operators.kiali.version}"
#       config = {
#         nodeSelector = {
#           "node-role.kubernetes.io/infra": ""
#         }
#       }
#     }
#   }
#   provisioner "local-exec" {
#     when = destroy
#     command = <<EOT
#     CSV=$(oc get subscription.operators.coreos.com ${self.manifest.metadata.name} -n ${self.manifest.metadata.namespace} -o=jsonpath='{.status.currentCSV}')
#     oc delete csv $CSV -n ${self.manifest.metadata.namespace}
#     EOT
#   }
# }

# resource "kubernetes_manifest" "distributed_tracing_operator" {
#   # count = 0
#   manifest = {
#     apiVersion = "operators.coreos.com/v1alpha1"
#     kind       = "Subscription"
#     metadata = {
#       name      = "jaeger-product"
#       namespace = "openshift-distributed-tracing"
#     }
#     spec: {
#       channel = var.operators.distributed_tracing.update_channel
#       installPlanApproval = "Automatic"
#       name = "jaeger-product"
#       source = "redhat-operators"
#       sourceNamespace = "openshift-marketplace"
#       startingCSV = "jaeger-operator.v${var.operators.distributed_tracing.version}"
#       config = {
#         nodeSelector = {
#           "node-role.kubernetes.io/infra": ""
#         }
#       }
#     }
#   }
#   provisioner "local-exec" {
#     when = destroy
#     command = <<EOT
#     CSV=$(oc get subscription.operators.coreos.com ${self.manifest.metadata.name} -n ${self.manifest.metadata.namespace} -o=jsonpath='{.status.currentCSV}')
#     oc delete csv $CSV -n ${self.manifest.metadata.namespace}
#     EOT
#   }
# }

# resource "kubernetes_manifest" "elasticsearch_operator" {
#   # count = 0
#   manifest = {
#     apiVersion = "operators.coreos.com/v1alpha1"
#     kind       = "Subscription"
#     metadata = {
#       name      = "elasticsearch-operator"
#       namespace = "openshift-operators-redhat"
#     }
#     spec: {
#       channel = var.operators.elasticsearch.update_channel
#       installPlanApproval = "Automatic"
#       name = "elasticsearch-operator"
#       source = "redhat-operators"
#       sourceNamespace = "openshift-marketplace"
#       startingCSV = "elasticsearch-operator.v${var.operators.elasticsearch.version}"
#       config = {
#         nodeSelector = {
#           "node-role.kubernetes.io/infra": ""
#         }
#       }
#     }
#   }
#   provisioner "local-exec" {
#     when = destroy
#     command = <<EOT
#     CSV=$(oc get subscription.operators.coreos.com ${self.manifest.metadata.name} -n ${self.manifest.metadata.namespace}  -o=jsonpath='{.status.currentCSV}')
#     oc delete csv $CSV -n ${self.manifest.metadata.namespace} 
#     EOT
#   }
# }

# resource "kubernetes_manifest" "service_mesh_operator" {
#   # count = 0
#   manifest = {
#     apiVersion = "operators.coreos.com/v1alpha1"
#     kind       = "Subscription"
#     metadata = {
#       name      = "servicemeshoperator"
#       namespace = "openshift-operators"
#     }
#     spec: {
#       channel = var.operators.service_mesh.update_channel
#       installPlanApproval = "Automatic"
#       name = "servicemeshoperator"
#       source = "redhat-operators"
#       sourceNamespace = "openshift-marketplace"
#       startingCSV = "servicemeshoperator.v${var.operators.service_mesh.version}"
#       config = {
#         nodeSelector = {
#           "node-role.kubernetes.io/infra": ""
#         }
#       }
#     }
#   }
#   provisioner "local-exec" {
#     when = destroy
#     command = <<EOT
#     CSV=$(oc get subscription.operators.coreos.com ${self.manifest.metadata.name} -n ${self.manifest.metadata.namespace} -o=jsonpath='{.status.currentCSV}')
#     oc delete csv $CSV -n ${self.manifest.metadata.namespace}
#     EOT
#   }
# }

