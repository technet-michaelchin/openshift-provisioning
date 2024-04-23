variable "base_domain" {
  type = string
  description = "Base domain for the OCP cluster"
}

variable "kubeconfig_path" {
  type = string
  default = "kubeconfig"
  description = "Path to the kubeconfig file"
}

variable "kubeconfig_context" {
  type = string
  default = "admin"
  description = "Kubeconfig context to use"
}

variable "minio_tenants" {
  type = list(object({
    root_user = string
    root_password = string
    name = string
    namespace = object({
      mcs = string
      supplemental_groups = string
      uid_range = string
    })
    users = list(object({
      name = string
      password = string
    }))
    numberOfServers = number
    storageClass = string
    volumeSize = string
    volumesPerServer = number
    buckets = list(string)
  }))
}

variable "logging" {
  type = object({
    s3 = object({
      access_key_id = string
      secret_access_key = string
      bucketnames = string
      endpoint = string
    })
  })
}