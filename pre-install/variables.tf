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

variable "operators" {
  type = map(object({
    update_channel = string
    version = string 
  }))
  default = {
    kiali = {
      update_channel = "stable"
      version = "1.73.7"
    }
    elasticsearch = {
      update_channel = "stable-5.8"
      version = "5.8.5"
    }
    distributed_tracing = {
      update_channel = "stable"
      version = "1.53.0-4"
    }
    service_mesh = {
      update_channel = "stable"
      version = "2.5.1"
    }
    minio = {
      update_channel = "stable"
      version = "5.0.14"
    }
    loki = {
      update_channel = "stable-5.9"
      version = "5.9.0"
    }
    logging = {
      update_channel = "stable-5.9"
      version = "5.9.0"
    }
  }
  description = "Operators to install"
}