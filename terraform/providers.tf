terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.7.1"
    }
  }
  backend "s3" {
    bucket  = "serhii-myronets"
    key     = "homelab/cluster.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "proxmox" {
  endpoint = "https://10.1.1.100:8006/"
  username = "root@pam"
  password = "tata3846"
  insecure = true
}