# Openshift Terraform Provisioning

## Operators

- Service Mesh
  - OpenShift Elasticsearch
  - Red Hat OpenShift distributed tracing platform (Jaeger)
  - Kiali Operator provided by Red Hat
  - Red Hat Openshift Service Mesh
- Logging
  - Minio Operator
  - Loki Operator
  - Logging Operator
- ...

### Default Config

```json
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
```

## Notice

- After the `terraform apply`, it need to take some time for the installation in openshift
- For deleting operators subscription, set `count=0` instead of directly remove the code block
  - https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax#destroy-time-provisioners
