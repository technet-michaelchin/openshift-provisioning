resource "kubernetes_manifest" "minio_operator_console_route" {
  manifest = yamldecode(templatefile("${path.module}/manifests/route.yml.tftpl", {
    name = "minio-operator-console"
    namespace = "minio-operator"
    host = "minio-operator-console.${var.base_domain}"
    target_port = 9443
    service = "console"
    termination = "passthrough"
    insecure_edge_termination_policy = "Redirect"
  }))
}

resource "kubernetes_namespace" "tenants" {
  for_each = {
    for tenant in var.minio_tenants:
    tenant.name => tenant 
  }
  metadata {
    name = each.key
    annotations = {
      "openshift.io/sa.scc.mcs"                 = each.value.namespace.mcs 
      "openshift.io/sa.scc.supplemental-groups" = each.value.namespace.supplemental_groups
      "openshift.io/sa.scc.uid-range"           = each.value.namespace.uid_range
    }
  }
}

resource "kubernetes_secret" "tenants_env" {
  for_each = {
    for tenant in var.minio_tenants:
    tenant.name => tenant
  }
  metadata {
    name = "minio-env-configuration"
    namespace = kubernetes_namespace.tenants[each.key].metadata[0].name
  }
  data = {
    "config.env" = <<EOF
export MINIO_ROOT_USER="${each.value.root_user}"
export MINIO_ROOT_PASSWORD="${each.value.root_password}"
EOF
  }
}

resource "kubernetes_secret" "tenants_users" {
  for_each = {
    for user in local.minio_users:
    "${user.namespace}-${user.user_name}" => user
  }
  metadata {
    name = each.value.user_name
    namespace = kubernetes_namespace.tenants[each.value.namespace].metadata[0].name
  }
  data = {
    "CONSOLE_ACCESS_KEY" = each.value.user_name
    "CONSOLE_SECRET_KEY" = each.value.user_password
  }
}

resource "kubernetes_manifest" "tenants" {
  for_each = {
    for tenant in var.minio_tenants:
    tenant.name => tenant
  }
  manifest = yamldecode(templatefile("${path.module}/manifests/minio/tenant.yml.tftpl", {
    namespace = kubernetes_namespace.tenants[each.key].metadata[0].name
    fs_group = tonumber(split("/", each.value.namespace.uid_range)[0])
    group = tonumber(split("/", each.value.namespace.uid_range)[0])
    user = tonumber(split("/", each.value.namespace.uid_range)[0])
    numberOfServers = each.value.numberOfServers
    volumeSize = each.value.volumeSize
    volumesPerServer = each.value.volumesPerServer
    storageClass = each.value.storageClass
    users = each.value.users
    buckets = each.value.buckets
  }))
}

resource "kubernetes_manifest" "tenants_route" {
  depends_on = [ kubernetes_manifest.tenants ]
  for_each = {
    for tenant in var.minio_tenants:
    tenant.name => tenant
  }
  manifest = yamldecode(templatefile("${path.module}/manifests/route.yml.tftpl", {
    name = "minio-${each.key}"
    namespace = kubernetes_namespace.tenants[each.key].metadata[0].name
    host = "minio-${each.key}.apps.${var.base_domain}"
    target_port = 9090
    service = "minio-console"
    termination = "edge"
    insecure_edge_termination_policy = "Redirect"
  }))
}

resource "kubernetes_manifest" "tenants_api_route" {
  depends_on = [ kubernetes_manifest.tenants ]
  for_each = {
    for tenant in var.minio_tenants:
    tenant.name => tenant
  }
  manifest = yamldecode(templatefile("${path.module}/manifests/route.yml.tftpl", {
    name = "minio-${each.key}-api"
    namespace = kubernetes_namespace.tenants[each.key].metadata[0].name
    host = "minio-${each.key}-api.apps.${var.base_domain}"
    target_port = 9000
    service = "minio"
    termination = "edge"
    insecure_edge_termination_policy = "Redirect"
  }))
}