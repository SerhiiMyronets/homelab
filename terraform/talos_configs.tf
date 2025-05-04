// ==============================================================================
// Talos Machine Secrets and Client Configuration
// ==============================================================================

resource "talos_machine_secrets" "machine_secrets" {}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [for node in local.controller_nodes : node.address]
}

// ==============================================================================
// Talos Cluster Kubeconfig
// ==============================================================================

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.bootstrap,
    # data.talos_cluster_health.health
  ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.controller_nodes[0].address
}

// ==============================================================================
// Talos Controlplane Node Configuration
// ==============================================================================

data "talos_machine_configuration" "controller" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = local.cluster_endpoint
  kubernetes_version = var.kubernetes_version
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
  config_patches     = local.config_patches_controller
}

resource "talos_machine_configuration_apply" "controller" {
  count                       = var.controller_config.count
  depends_on                  = [proxmox_virtual_environment_vm.control_plane]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controller.machine_configuration
  endpoint                    = local.controller_nodes[count.index].address
  node                        = local.controller_nodes[count.index].address
}

// ==============================================================================
// Talos Worker Node Configuration
// ==============================================================================

data "talos_machine_configuration" "worker" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = local.cluster_endpoint
  kubernetes_version = var.kubernetes_version
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
  config_patches     = local.config_patches_worker
}

resource "talos_machine_configuration_apply" "worker" {
  count                       = var.worker_config.count
  depends_on                  = [proxmox_virtual_environment_vm.talos_worker_01]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  endpoint                    = local.worker_nodes[count.index].address
  node                        = local.worker_nodes[count.index].address
}

// ==============================================================================
// Talos Cluster Bootstrap
// ==============================================================================

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [talos_machine_configuration_apply.controller]
  endpoint             = local.controller_nodes[0].address
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.controller_nodes[0].address
}


# data "talos_cluster_health" "health" {
#   depends_on = [talos_machine_bootstrap.bootstrap]
#   client_configuration = data.talos_client_configuration.talosconfig.client_configuration
#   control_plane_nodes = [for node in local.controller_nodes : node.address]
#   worker_nodes = [for node in local.worker_nodes : node.address]
#   endpoints            = [local.cluster_endpoint]
# }