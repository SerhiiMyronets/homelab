locals {
  controller_nodes = [
    for i in range(var.controller_config.count) : {
      name    = "controlplane-0${i + 1}"
      address = cidrhost(var.cluster_node_network, var.cluster_node_network_first_controller_hostnum + i)
    }
  ]
  worker_nodes = [
    for i in range(var.worker_config.count) : {
      name    = "worker-0${i + 1}"
      address = cidrhost(var.cluster_node_network, var.cluster_node_network_first_worker_hostnum + i)
    }
  ]


}

locals {
  patch_files = fileset("${path.module}/patches", "*.yaml")

  patches = [
    for patch_file in local.patch_files : yamldecode(file("${path.module}/patches/${patch_file}"))
  ]

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

  config_patches_worker = [
    for patch in local.patches : yamlencode(patch)
  ]

  config_patches_controlplane = [
    for patch in concat(
      local.patches,
      [local.cilium_inline_manifest]
    ) : yamlencode(patch)
  ]
}
