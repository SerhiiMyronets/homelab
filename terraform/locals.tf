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


  patch_files = fileset("${path.module}/patches", "*.yaml")

  patches = [
    for patch_file in local.patch_files : yamlencode(
      yamldecode(file("${path.module}/patches/${patch_file}"))
    )
  ]
}

