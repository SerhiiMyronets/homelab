// ==============================================================================
// Proxmox Credentials
// ==============================================================================

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
  default     = "tata3846" // Replace with your actual Proxmox password before deploying.
}

// ==============================================================================
// Global Cluster Settings
// ==============================================================================

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

// ==============================================================================
// Proxmox Node Settings
// ==============================================================================

variable "proxmox_node_name" {
  description = "The name of the Proxmox node where virtual machines are created."
  type        = string
  default     = "proxmox"
}

variable "proxmox_network_bridge" {
  description = "The network bridge interface on Proxmox used by virtual machines."
  type        = string
  default     = "vmbr0"
}

// ==============================================================================
// Talos Settings
// ==============================================================================

variable "talos_version" {
  description = "Talos Linux version."
  type        = string
  default     = "v1.9.5"
}

variable "talos_qemu_drbd_hash" {
  description = "SHA256 hash of the Talos Linux image for QEMU/ISCSI."
  type        = string
  default     = "dc7b152cb3ea99b821fcb7340ce7168313ce393d663740b791c36f6e95fc8586"
}

locals {
  talos_image_url      = "https://factory.talos.dev/image/${var.talos_qemu_drbd_hash}/${var.talos_version}/nocloud-amd64.raw.gz"
  talos_image_filename = "talos-${var.talos_version}-nocloud-amd64.img"
}

variable "kubernetes_version" {
  type    = string
  default = "1.32.0"
}



// ==============================================================================
// Cluster Network Settings
// ==============================================================================

variable "cluster_node_network" {
  description = "The CIDR block for the Kubernetes nodes network."
  type        = string
  default     = "10.1.1.0/24"
}

variable "cluster_node_network_gateway" {
  description = "The gateway IP address for the Kubernetes nodes network."
  type        = string
  default     = "10.1.1.1"
}

variable "cluster_node_network_first_controller_hostnum" {
  description = <<-EOT
    Host number for the first controlplane node.
    Example: If network is 10.1.1.0/24 and hostnum is 80, the node IP will be 10.1.1.80.
  EOT
  type        = number
  default     = 80
}

variable "cluster_node_network_first_worker_hostnum" {
  description = <<-EOT
    Host number for the first worker node.
    Example: If network is 10.1.1.0/24 and hostnum is 90, the node IP will be 10.1.1.90.
  EOT
  type        = number
  default     = 90
}

variable "cluster_node_network_load_balancer_first_hostnum" {
  description = <<-EOT
    Host number for the first IP address allocated to LoadBalancer services.
    Example: If the network is 10.1.1.0/24 and this is set to 130, the IP will be 10.1.1.130.
  EOT
  type        = number
  default     = 130
}

variable "cluster_node_network_load_balancer_last_hostnum" {
  description = <<-EOT
    Host number for the last IP address allocated to LoadBalancer services.
    Example: If this is set to 230, the last IP will be 10.1.1.230.
  EOT
  type        = number
  default     = 230
}

// ==============================================================================
// Node Resource Configuration
// ==============================================================================

variable "controller_config" {
  description = "Resource configuration for controlplane nodes."
  type = object({
    count  = number
    cpu    = number
    memory = number
    disk   = number
  })
  default = {
    count  = 1
    cpu    = 4
    memory = 4096 * 2 // 4 GB
    disk   = 40   // 40 GB
  }
}

variable "worker_config" {
  description = "Resource configuration for worker nodes."
  type = object({
    count         = number
    cpu           = number
    memory        = number
    disk_os       = number
    disk-longhorn = number
  })
  default = {
    count         = 1
    cpu           = 16
    memory        = 16384 * 3 // 8 GB
    disk_os       = 40   // 40 GB
    disk-longhorn = 60   // 60 GB
  }
}

// ==============================================================================
// Kubernetes API VIP Settings
// ==============================================================================

variable "cluster_vip" {
  description = "The Virtual IP used by controller nodes for the Kubernetes API (should be in same subnet)."
  type        = string
  default     = "10.1.1.50"
}

locals {
  cluster_endpoint = "https://${var.cluster_vip}:6443"
}