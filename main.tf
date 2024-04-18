locals {
  minio_users = flatten([
    for tenant in var.minio_tenants:
    [
      for user in tenant.users:
      {
        namespace = tenant.name
        user_name = user.name
        user_password = user.password
      }
    ]
  ])
}
