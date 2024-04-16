# resource "kubernetes_namespace" "istio_system" {
#   metadata {
#     name = "istio-system"
#     annotations = {
#       "openshift.io/sa.scc.mcs"                 = "s0:c28,c12" 
#       "openshift.io/sa.scc.supplemental-groups" = "1000780000/10000" 
#       "openshift.io/sa.scc.uid-range"           = "1000780000/10000" 
#     }
#     labels = {
#       "maistra.io/member-of" = "istio-system"
#       "kiali.io/member-of"   = "istio-system"
#     }
#   }
# }

# resource "kubernetes_manifest" "service_mesh_control_plane" {
#   manifest = {
#     apiVersion = "maistra.io/v2"
#     kind       = "ServiceMeshControlPlane"
#     metadata = {
#       name = "basic"
#       namespace = kubernetes_namespace.istio_system.metadata[0].name
#     }
#     spec = {
#       runtime = {
#         defaults = {
#           pod = {
#             nodeSelector = {
#               "node-role.kubernetes.io/infra": ""
#             }
#             tolerations = [
#               {
#                 effect = "NoSchedule"
#                 key = "node-role.kubernetes.io/infra"
#                 value = "reserved"
#               },
#               {
#                 effect = "NoExecute"
#                 key = "node-role.kubernetes.io/infra"
#                 value = "reserved"
#               }
#             ]
#           }
#         }
#       }
#       version = "v2.5"
#       tracing = {
#         type = "Jaeger"
#         sampling = 10000
#       }
#       addons = {
#         jaeger = {
#           name = "jaeger"
#           install = {
#             storage = {
#               type = "Memory"
#             }
#             # storage = {
#             #   type = "Elasticsearch"
#             # }
#             # ingress = {
#             #   enabled = true
#             # }
#           }
#         }
#         kiali = {
#           enabled = true
#           name = "kiali"
#         }
#         grafana = {
#           enabled = true
#         }
#       }
#     }
#   }
# }