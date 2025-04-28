terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
  }
  backend "s3" {
    bucket  = "serhii-myronets"
    key     = "homelab/helm.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config")
  }
}


resource "helm_release" "cilium" {
  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.15.2"
  create_namespace = false

  values = [
    yamlencode({
      securityContext = {
        privileged = false
      }
      cleanState = {
        enabled = false
      }
      kubeProxyReplacement = "strict"
      loadBalancer = {
        enabled = true
        ipam = {
          operator = {
            enabled = true
            clusterPoolIPv4PodCIDR = "10.2.0.0/16"
            clusterPoolIPv4MaskSize = 24
            ipPools = [
              {
                cidr = "10.1.1.200/29"
              }
            ]
          }
        }
      }
    })
  ]
}
