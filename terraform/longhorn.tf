# // ==============================================================================
# // Helm Template for Longhorn
# // ==============================================================================
#
# data "helm_template" "longhorn" {
#   name         = "longhorn"
#   namespace    = "longhorn-system"
#   repository   = "https://charts.longhorn.io"
#   chart        = "longhorn"
#   version      = "1.5.3"
#   kube_version = var.kubernetes_version
#   api_versions = []
#
#   values = [yamlencode(local.longhorn_helm_values)]
# }
#
# // ==============================================================================
# // Longhorn Helm Chart Values
# // ==============================================================================
#
# locals {
#   longhorn_helm_values = {
#     serviceAccount = {
#       create = true
#     }
#
#     defaultSettings = {
#       defaultReplicaCount = 1
#       defaultDataPath     = "/var/lib/longhorn"
#     }
#
#     longhornUI = {
#       replicas = 1
#     }
#
#     # Redisabling default ingress to avoid exposure unless configured explicitly
#     ingress = {
#       enabled = false
#     }
#   }
# }
#
# // ==============================================================================
# // Longhorn Inline Manifests for Talos
# // ==============================================================================
#
# locals {
#   longhorn_namespace_manifest = yamlencode({
#     apiVersion = "v1"
#     kind       = "Namespace"
#     metadata = {
#       name = "longhorn-system"
#       labels = {
#         "pod-security.kubernetes.io/enforce" = "privileged"
#       }
#     }
#   })
#
#   longhorn_inline_manifest = {
#     cluster = {
#       inlineManifests = [
#         {
#           name     = data.helm_template.longhorn.namespace
#           contents = join("---\n", [
#             local.longhorn_namespace_manifest,
#             data.helm_template.longhorn.manifest
#           ])
#         }
#       ]
#     }
#   }
# }

# resource "helm_release" "longhorn" {
#   provider   = helm
#   name       = "longhorn"
#   namespace  = "longhorn-system"
#   repository = "https://charts.longhorn.io"
#   chart      = "longhorn"
#   version    = "1.5.3"
#
#   create_namespace = true
#
#   values = [
#     yamlencode({
#       serviceAccount = {
#         create = true
#       }
#     })
#   ]
#
#   depends_on = [talos_machine_bootstrap.bootstrap]
# }
