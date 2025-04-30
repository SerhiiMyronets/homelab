# 🛠️ Prerequisites for Running Talos Kubernetes Cluster on Proxmox

This guide will walk you through preparing your machine to run a Kubernetes cluster using Talos and Terraform on Proxmox. It's designed for home lab enthusiasts and beginners who want to experiment with modern infrastructure using simple and affordable hardware.

---

## 💻 Minimum Server Requirements

You don’t need any special server or enterprise hardware. A spare laptop or mini PC with virtualization support is enough to get started. This setup is designed to be beginner-friendly and lightweight.

| Resource  | Minimum (for testing) | Recommended (for smooth usage) |
| --------- | --------------------- | ------------------------------ |
| CPU Cores | 4                     | 8+                             |
| RAM       | 8 GB                  | 16 GB+                         |

> 💡 For running the full GitOps setup (including observability stack, demo apps, and load generator), 12 GB+ RAM is minimum.

---

## 📦 Software Dependencies

To deploy and manage the cluster, you’ll need to install a few command-line tools. Most of them are cross-platform and easy to install using your system’s package manager. Below are the commands for macOS and Ubuntu/Debian.

You'll need a few command-line tools installed on your **local machine** (not inside Proxmox). Below are the required and optional ones:

### ✅ Required

These are essential to deploy and manage the cluster:

* `terraform` — for provisioning the infrastructure
* `kubectl` — to interact with the Kubernetes cluster
* `helmfile` — to manage Helm charts declaratively
* `helm` — needed by `helmfile`

### 🧩 Optional

These tools are useful but not strictly required:

* `talosctl` — to interact with Talos Linux nodes (e.g., logs, debugging)
* `cilium` — CLI for Cilium CNI management and troubleshooting

```bash
# macOS (Homebrew)
brew install terraform kubectl helmfile helm
brew install talosctl cilium

# Ubuntu/Debian (APT)
sudo apt update && sudo apt install -y terraform kubectl helmfile helm
# talosctl and cilium usually require manual install or downloading binaries
```

Or use your distro's package manager if on Linux.

---

## 🖥️ Install Proxmox VE

Proxmox is a free and powerful tool that lets you run virtual machines on your PC. You’ll need to install it directly on the machine that will host your Kubernetes cluster.

Download the ISO here: [https://www.proxmox.com/en/downloads](https://www.proxmox.com/en/downloads)

**Steps:**

1. Download the ISO and flash it to a USB stick using a tool like Balena Etcher or Raspberry Pi Imager
2. Boot your PC or laptop from the USB and install Proxmox
3. Once installed, access the Proxmox web interface from another device: `https://<your-proxmox-ip>:8006`

> 💡 Tip: You may need to enable virtualization in BIOS (look for Intel VT-x or AMD-V)

---

## ⚙️ Post-Install Configuration for Proxmox

After installing Proxmox, it's a good idea to run a quick setup script that configures repositories, enables community features, and sets up basic networking defaults.

💡 This will save time and avoid common issues with missing packages or unconfigured interfaces.

### 🔧 Run Post-Install Script

You can execute the following script directly on your Proxmox host:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh)"
```

This script will:

* Enable community repositories
* Update package lists
* Fix subscription-related prompts in the UI
* Configure basic system settings

Once done, continue with the network configuration below.

---

### 🧩 Network Interface Configuration

To make the Kubernetes cluster work in a separate and clean environment, I recommend creating an **isolated bridge with NAT**. This keeps your home network untouched and avoids changing router settings. You’ll need to modify the network interface settings on your Proxmox host.

> 🖍️ **Important:** Your real network interface (e.g. `enp3s0`) will likely be **different** from mine. Make sure to replace it everywhere — it appears **4 times** in the config below.
> Run `ip a` or `ip link` on the Proxmox host to find the correct interface and replace `enp3s0` in the config below.

Also, if `192.168.1.100` is available on your home network, **I recommend keeping it**, since the rest of this project assumes that IP by default — this way you'll avoid extra configuration changes later.

Here’s an example `/etc/network/interfaces` config:

```ini
# loopback
auto lo
iface lo inet loopback

# main physical interface
auto enp3s0
iface enp3s0 inet static
    address  192.168.1.100/24
    gateway  192.168.1.1

# isolated bridge for Kubernetes cluster
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

Once you’ve made changes, apply the config with:

```bash
ifreload -a
```

---

## 🌍 Route Setup on Your Local Machine (Mac/Linux)

To connect to the Kubernetes cluster from your regular computer (e.g. laptop), you’ll need to add a static route for the cluster subnet. Without this route, Terraform won’t be able to communicate with the Talos nodes to complete the setup.

If your Proxmox host IP is `192.168.1.100`, you can add the route like this:

```bash
sudo route -n add 192.168.100.0/24 192.168.1.100
```

This tells your system to forward all traffic for the cluster (192.168.100.x) through the Proxmox host.

This routes cluster traffic through your Proxmox box.

---

Ready? ➡️ Move on to [01-infrastructure](../01-infrastructure/) to start deploying your cluster!
