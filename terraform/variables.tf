variable "cluster_name" {
  type    = string
  default = "homelab"
}

variable "proxmox_pve_node_name" {
  type    = string
  default = "proxmox"
}

variable "default_gateway" {
  type    = string
  default = "10.1.1.1"
}

variable "talos_cp_01_ip_addr" {
  type    = string
  default = "10.1.1.201"
}

variable "talos_worker_01_ip_addr" {
  type    = string
  default = "10.1.1.202"
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