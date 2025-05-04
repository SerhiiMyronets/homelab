# // ==============================================================================
# // Helm Template for Cilium
# // ==============================================================================
#
# data "helm_template" "cilium" {
#   namespace    = "kube-system"
#   name         = "cilium"
#   repository   = "https://helm.cilium.io"
#   chart        = "cilium"
#   version      = "1.16.4"
#   kube_version = var.kubernetes_version
#   api_versions = []
#
#   values = [yamlencode(local.cilium_helm_values)]
# }
#
# // ==============================================================================
# // Cilium Helm Chart Values
# // ==============================================================================
#
# locals {
#   cilium_helm_values = {
#     ipam = {
#       mode = "kubernetes"
#     }
#     securityContext = {
#       capabilities = {
#         ciliumAgent      = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
#         cleanCiliumState = ["NET_ADMIN", "SYS_ADMIN", "SYS_RESOURCE"]
#       }
#     }
#     cgroup = {
#       autoMount = {
#         enabled = false
#       }
#       hostRoot = "/sys/fs/cgroup"
#     }
#     k8sServiceHost       = "localhost"
#     k8sServicePort       = "7445"
#     kubeProxyReplacement = true
#     l2announcements = {
#       enabled = true
#     }
#     envoy = {
#       enabled = false
#     }
#     hubble = {
#       relay = {
#         enabled = true
#       }
#       ui = {
#         enabled = true
#       }
#     }
#   }
# }
#
# // ==============================================================================
# // Cilium Load Balancer Inline Manifests for Talos
# // ==============================================================================
#
# locals {
#   cilium_main_manifest = data.helm_template.cilium.manifest
#
#   cilium_l2_announcement_policy = yamlencode({
#     apiVersion = "cilium.io/v2alpha1"
#     kind       = "CiliumL2AnnouncementPolicy"
#     metadata = {
#       name = "external"
#     }
#     spec = {
#       loadBalancerIPs = true
#       interfaces      = ["eth0"]
#       nodeSelector = {
#         matchExpressions = [
#           {
#             key      = "node-role.kubernetes.io/control-plane"
#             operator = "DoesNotExist"
#           }
#         ]
#       }
#     }
#   })
#
#   cilium_lb_ip_pool = yamlencode({
#     apiVersion = "cilium.io/v2alpha1"
#     kind       = "CiliumLoadBalancerIPPool"
#     metadata = {
#       name = "external"
#     }
#     spec = {
#       blocks = [
#         {
#           start = cidrhost(var.cluster_node_network, var.cluster_node_network_load_balancer_first_hostnum)
#           stop  = cidrhost(var.cluster_node_network, var.cluster_node_network_load_balancer_last_hostnum)
#         }
#       ]
#     }
#   })
#
#   cilium_inline_manifest = {
#     cluster = {
#       inlineManifests = [
#         {
#           name = "cilium"
#           contents = join("---\n", [
#             local.cilium_main_manifest,
#             local.cilium_l2_announcement_policy,
#             local.cilium_lb_ip_pool,
#           ])
#         }
#       ]
#     }
#   }
# }
# resource "helm_release" "cilium" {
#   name       = "cilium"
#   namespace  = "kube-system"
#   repository = "https://helm.cilium.io"
#   chart      = "cilium"
#   version    = "1.16.4"
#
#   create_namespace = false
#
#   values = [
#     yamlencode({
#       ipam = {
#         mode = "kubernetes"
#       },
#       securityContext = {
#         capabilities = {
#           ciliumAgent      = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
#           cleanCiliumState = ["NET_ADMIN", "SYS_ADMIN", "SYS_RESOURCE"]
#         }
#       },
#       cgroup = {
#         autoMount = {
#           enabled = false
#         },
#         hostRoot = "/sys/fs/cgroup"
#       },
#       k8sServiceHost       = "localhost"
#       k8sServicePort       = "7445"
#       kubeProxyReplacement = true
#       l2announcements = {
#         enabled = true
#       },
#       devices = ["eth0"],
#       envoy = {
#         enabled = false
#       },
#       hubble = {
#         relay = {
#           enabled = true
#         },
#         ui = {
#           enabled = true
#         }
#       }
#     })
#   ]
#
#   depends_on = [talos_machine_bootstrap.bootstrap]
# }
