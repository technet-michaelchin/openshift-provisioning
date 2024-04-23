# kialis.kiali.io has the finalizer "kiali.io/finalizer" in istio-system namespace
resource "kubernetes_namespace" "istio_system" {
  depends_on = [ 
    kubernetes_manifest.loki_stack,
  ]
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

# need to delete this before delete the operator, otherwise this will become an orphaned resource
resource "kubernetes_manifest" "control_plane" {
  depends_on = [ 
    kubernetes_manifest.loki_stack,
  ]
  manifest = yamldecode(templatefile("${path.module}/manifests/service-mesh/control-plane.yml.tftpl", {
    namespace = kubernetes_namespace.istio_system.metadata[0].name
  }))
}
