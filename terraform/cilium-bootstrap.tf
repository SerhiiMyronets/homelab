// ==============================================================================
// Helm Template for Cilium
// ==============================================================================

data "helm_template" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.15.6"
  namespace  = "kube-system"

  values = [
    yamlencode({
      ipam = {
        mode = "kubernetes"
      }

      kubeProxyReplacement = true

      securityContext = {
        capabilities = {
          ciliumAgent      = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
          cleanCiliumState = ["NET_ADMIN", "SYS_ADMIN", "SYS_RESOURCE"]
        }
      }

      cgroup = {
        autoMount = {
          enabled = false
        }
        hostRoot = "/sys/fs/cgroup"
      }

      k8sServiceHost = "localhost"
      k8sServicePort = 7445
    })
  ]
}

// ==============================================================================
// Cilium Inline Manifest for Talos
// ==============================================================================

locals {
  cilium_inline_manifest = {
    cluster = {
      inlineManifests = [
        {
          name     = "cilium"
          contents = data.helm_template.cilium.manifest
        }
      ]
    }
  }
}
