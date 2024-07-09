// ==============================================================================
// Helm Template for ArgoCD
// ==============================================================================

data "helm_template" "argocd" {
  namespace    = "argocd"
  name         = "argocd"
  repository   = "https://argoproj.github.io/argo-helm"
  chart        = "argo-cd"
  version      = "7.7.7"
  kube_version = var.kubernetes_version
  api_versions = []

  values = [yamlencode(local.argocd_helm_values)]
}

// ==============================================================================
// ArgoCD Helm Chart Values
// ==============================================================================

locals {
  argocd_helm_values = {
    server = {
      service = {
        type = "LoadBalancer"
      }
    }
  }
}

// ==============================================================================
// ArgoCD Inline Manifests for Talos
// ==============================================================================

locals {
  argocd_namespace_manifest = yamlencode({
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = "argocd"
    }
  })
  argocd_cm_manifest = yamlencode({
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = "argocd-cm"
      namespace = "argocd"
    }
    data = {
      "kustomize.buildOptions" = "--enable-helm"
    }
  })
  argocd_inline_manifest = {
    cluster = {
      inlineManifests = [
        {
          name     = data.helm_template.argocd.namespace
          contents = join("---\n", [
            local.argocd_namespace_manifest,
            # local.argocd_cm_manifest,
            data.helm_template.argocd.manifest
          ])
        }
      ]
    }
  }
}


# helm upgrade --install argocd argo/argo-cd \
# --namespace argocd \
# --create-namespace \
# --set "configs.cm.kustomize\.buildOptions=--enable-helm" \
# --set redis.auth.enabled=false \
# --set server.service.type=LoadBalancer