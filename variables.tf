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
      version = "1.73.4"
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
      version = "2.5.0"
    }
    minio = {
      update_channel = "stable"
      version = "5.0.13"
    }
  }
  description = "Operators to install"
}

