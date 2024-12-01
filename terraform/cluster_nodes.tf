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

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"

  file_name               = "talos-${local.talos.version}-nocloud-amd64.img"
  url                     = "https://factory.talos.dev/image/6adc7e7fba27948460e2231e5272e88b85159da3f3db980551976bf9898ff64b/${local.talos.version}/nocloud-amd64.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = true
  overwrite_unmanaged     = true
}