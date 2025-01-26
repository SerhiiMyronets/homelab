// =============================
// Proxmox Credentials
// =============================

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL."
  type        = string
  default     = "https://10.1.1.100:8006/"
}

variable "proxmox_username" {
  description = "Proxmox API username."
  type        = string
  default     = "root@pam"
}

variable "proxmox_password" {
  description = "Proxmox API password."
  type        = string
  sensitive   = true
  default     = "tata3846" // ⚡ Replace with your actual Proxmox password before deploying
}

// =============================
// Global Cluster Settings
// =============================

variable "cluster_name" {
  description = "The name of the Kubernetes cluster. Used in resource naming."
  type        = string
  default     = "homelab"
}

variable "prefix" {
  description = "Prefix used for virtual machine names."
  type        = string
  default     = "talos"
}

// =============================
// Proxmox Settings
// =============================

variable "proxmox_node_name" {
  description = "The name of the Proxmox node where virtual machines are created."
  type        = string
  default     = "proxmox"
}

variable "proxmox_network_bridge" {
  description = "The name of the network bridge interface on Proxmox used by virtual machines."
  type        = string
  default     = "vmbr0"
}

// =============================
// Talos Settings
// =============================

locals {
  talos = {
    version = "v1.9.4" // Current Talos Linux version used for provisioning.
  }
}

// =============================
// Cluster Network Settings
// =============================

variable "cluster_node_network" {
  description = "The CIDR network block for Kubernetes nodes."
  type        = string
  default     = "10.1.1.0/24"
}

variable "cluster_node_network_gateway" {
  description = "The IP address of the network gateway for Kubernetes nodes."
  type        = string
  default     = "10.1.1.1"
}

variable "cluster_node_network_first_controller_hostnum" {
  description = <<-EOT
    Host number for the first controlplane node.
    Example: In network 10.1.1.0/24 and hostnum 80, the node IP will be 10.1.1.80.
  EOT
  type        = number
  default     = 80
}

variable "cluster_node_network_first_worker_hostnum" {
  description = <<-EOT
    Host number for the first worker node.
    Example: In network 10.1.1.0/24 and hostnum 90, the node IP will be 10.1.1.90.
  EOT
  type        = number
  default     = 90
}

// =============================
// Node Resource Configuration
// =============================

variable "controller_config" {
  description = "Resource configuration for controlplane nodes."
  type = object({
    count  = number
    cpu    = number
    memory = number
    disk   = number
  })
  default = {
    count  = 3
    cpu    = 4
    memory = 4096 // 4 GB
    disk   = 40   // 40 GB
  }
}

variable "worker_config" {
  description = "Resource configuration for worker nodes."
  type = object({
    count  = number
    cpu    = number
    memory = number
    disk   = number
  })
  default = {
    count  = 2
    cpu    = 2
    memory = 4096 // 4 GB
    disk   = 40   // 40 GB
  }
}

variable "cluster_vip" {
  description = "The virtual IP (VIP) address of the Kubernetes API server. Ensure it is synchronized with the 'cluster_endpoint' variable."
  type        = string
  default     = "10.1.1.50"
}

variable "cluster_endpoint" {
  description = "The virtual IP (VIP) endpoint of the Kubernetes API server. Ensure it is synchronized with the 'cluster_vip' variable."
  type        = string
  default     = "https://10.1.1.50:6443"
}