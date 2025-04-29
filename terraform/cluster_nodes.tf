// ==============================================================================
// Talos Proxmox Image Download
// ==============================================================================

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type            = "iso"
  datastore_id            = "local"
  node_name               = var.proxmox_node_name
  file_name               = local.talos_image_filename
  url                     = local.talos_image_url
  decompression_algorithm = "gz"
  overwrite               = true
  overwrite_unmanaged     = true
}

// ==============================================================================
// Talos Control Plane Virtual Machines
// ==============================================================================

resource "proxmox_virtual_environment_vm" "control_plane" {
  count           = var.controller_config.count
  name            = "${var.prefix}-${local.controller_nodes[count.index].name}"
  tags            = sort(["talos", "control_plane", "terraform"])
  stop_on_destroy = true
  node_name       = var.proxmox_node_name
  on_boot         = true

  cpu {
    cores = var.controller_config.cpu
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.controller_config.memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = var.proxmox_network_bridge
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = var.controller_config.disk
  }

  operating_system {
    type = "l26"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${local.controller_nodes[count.index].address}/24"
        gateway = var.cluster_node_network_gateway
      }
    }
  }
}

// ==============================================================================
// Talos Worker Virtual Machines
// ==============================================================================

resource "proxmox_virtual_environment_vm" "talos_worker_01" {
  depends_on = [proxmox_virtual_environment_vm.control_plane]
  count      = var.worker_config.count
  name       = "${var.prefix}-${local.worker_nodes[count.index].name}"
  tags       = sort(["talos", "worker", "terraform"])
  node_name  = var.proxmox_node_name
  on_boot    = true

  cpu {
    cores = var.worker_config.cpu
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.worker_config.memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = var.proxmox_network_bridge
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = var.worker_config.disk
  }

  operating_system {
    type = "l26"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${local.worker_nodes[count.index].address}/24"
        gateway = var.cluster_node_network_gateway
      }
    }
  }
}
