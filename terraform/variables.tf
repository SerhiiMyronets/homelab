variable "cluster_name" {
  type    = string
  default = "homelab"
}

variable "proxmox_pve_node_name" {
  type    = string
  default = "proxmox"
}

variable "cluster_node_network_gateway" {
  description = "The IP network gateway of the cluster nodes"
  type        = string
  default     = "10.1.1.1"
}

variable "network" {
  type    = string
  default = "vmbr0"
}

locals {
  talos = {
    version = "v1.9.4"
  }
}

variable "controller_config" {
  default = {
    count  = 3
    cpu    = 4
    memory = 4 * 1024
    disk   = 40
  }
}

variable "worker_config" {
  default = {
    count  = 2
    cpu    = 2
    memory = 4 * 1024
    disk   = 40
  }
}

variable "prefix" {
  type    = string
  default = "talos"
}


variable "cluster_node_network" {
  description = "The IP network of the cluster nodes"
  type        = string
  default     = "10.1.1.0/24"
}

variable "cluster_node_network_first_controller_hostnum" {
  description = "The hostnum of the first controller host"
  type        = number
  default     = 80
}

variable "cluster_node_network_first_worker_hostnum" {
  description = "The hostnum of the first worker host"
  type        = number
  default     = 90
}

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