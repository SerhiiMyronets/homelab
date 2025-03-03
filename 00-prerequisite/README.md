
# Prerequisites for Running Talos Kubernetes Cluster on Proxmox

This document describes the prerequisites and initial environment setup required to deploy a Kubernetes cluster using Talos Linux, Terraform, and Proxmox VE.

---

## Minimum Hardware Requirements

A physical server, mini PC, or spare laptop with virtualization support is sufficient.

| Resource    | Minimum (testing) | Recommended (production-like) |
|-------------|-------------------|-------------------------------|
| CPU Cores   | 4                 | 8+                            |
| RAM         | 8 GB              | 16 GB+                        |

> For running the full GitOps stack (observability, demo apps, load generation), at least 12 GB RAM is recommended.

---

## Required Software

Install the following CLI tools on your **local workstation** (not inside Proxmox):

### Mandatory

- `terraform`: Infrastructure provisioning
- `kubectl`: Kubernetes control interface
- `helmfile`: Declarative Helm release management
- `helm`: Dependency of `helmfile`

### Optional

- `talosctl`: Talos Linux management CLI
- `cilium`: Cilium CLI for CNI diagnostics

#### Installation (macOS / Ubuntu)

**macOS (Homebrew):**
```bash
brew install terraform kubectl helmfile helm
brew install talosctl cilium
```

**Ubuntu/Debian (APT + manual binaries):**
```bash
sudo apt update && sudo apt install -y terraform kubectl helmfile helm
# talosctl and cilium must be downloaded manually
```

---

## Proxmox VE Installation

Proxmox must be installed directly on the host machine that will run the cluster.

1. Download ISO: https://www.proxmox.com/en/downloads
2. Flash to USB (e.g., with Balena Etcher)
3. Boot the machine and install Proxmox
4. Access the UI: `https://<proxmox-ip>:8006`

> Ensure virtualization support (VT-x / AMD-V) is enabled in BIOS/UEFI.

---

## Post-Install Configuration

Run a standard setup script to configure repositories and base settings:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh)"
```

This will:
- Enable community repositories
- Update package lists
- Remove subscription notices
- Apply default Proxmox tweaks

---

## Proxmox Network Configuration

To isolate the Kubernetes cluster, configure a dedicated bridge (`vmbr1`) with NAT on the Proxmox host. This prevents interference with your home network.

> Replace all instances of `enp3s0` with your actual network interface (check via `ip a` or `ip link`).

Example `/etc/network/interfaces`:

```ini
# loopback
auto lo
iface lo inet loopback

# main interface
auto enp3s0
iface enp3s0 inet static
    address  192.168.1.100/24
    gateway  192.168.1.1

# isolated bridge for cluster
auto vmbr1
iface vmbr1 inet static
    address  192.168.100.1/24
    bridge-ports none
    bridge-stp off
    bridge-fd 0

    post-up   echo 1 > /proc/sys/net/ipv4/ip_forward
    post-up   iptables -t nat -A POSTROUTING -s '192.168.100.0/24' -o enp3s0 -j MASQUERADE
    post-down iptables -t nat -D POSTROUTING -s '192.168.100.0/24' -o enp3s0 -j MASQUERADE

source /etc/network/interfaces.d/*
```

Apply changes with:

```bash
ifreload -a
```

---

## Static Route (Local Machine)

To allow your workstation to reach Talos nodes inside the isolated network, add a static route:

```bash
sudo route -n add 192.168.100.0/24 192.168.1.100
```

Replace `192.168.1.100` with your Proxmox host's IP address.

---

## Navigation

[← Back to Main project README](../README.md) • [→ Continue to 01-infrastructure](../01-infrastructure/README.md)

