# Homelab Kubernetes Cluster with Talos, Terraform, and Proxmox

This project sets up a minimal, production-like Kubernetes cluster in a home environment using **Talos Linux**, **Terraform**, **Proxmox VE**, and **Cilium** for networking.

The goal is to create a clean, easily reproducible infrastructure that is lightweight, secure, and a perfect platform for experimentation, learning, and self-hosted applications.

---

## 🚀 Project Overview

- **Hypervisor:** Proxmox VE (PVE)
- **Operating System:** Talos Linux (Immutable Kubernetes OS)
- **Infrastructure as Code:** Terraform
- **Networking:** Cilium (kube-proxy replacement with eBPF)
- **Bootstrap Method:** KubePrism on Talos, Helm templated Cilium installation
- **Future Extensibility:** ArgoCD GitOps, monitoring stack, ingress controllers

---

## 📦 Project Structure

```plaintext
homelab/
├── kubernetes/            # Reserved for GitOps apps and ArgoCD manifests
├── terraform/
│   ├── cluster/
│   │   ├── patches/            # Talos configuration patches (kubeprism, hostdns, etc.)
│   │   │   ├── 00-enable-kubeprism.yaml
│   │   │   ├── 01-enable-hostdns.yaml
│   │   │   ├── 02-enable-cluster_discovery.yaml
│   │   │   ├── 03-disable-network_cni.yaml
│   │   │   ├── 04-disable-kubeproxy.yaml
│   │   │   └── 05-enable-drbd-modules.yaml
│   │   ├── cilium-bootstrap.tf # Bootstrap minimal Cilium network layer
│   │   ├── cluster_nodes.tf    # Virtual machines definition for controlplanes and workers
│   │   ├── locals.tf           # Local variables, patches handling
│   │   ├── outputs.tf          # Terraform outputs
│   │   ├── providers.tf        # Required providers and backend config
│   │   ├── proxmox_provider.tf # Proxmox provider credentials and connection
│   │   ├── talos_configs.tf    # Talos machine configurations (controlplane and worker)
│   │   └── variables.tf        # All input variables
├── .gitignore
└── README.md (this file)


---

## ⚙️ Requirements

- Proxmox VE running with a working network bridge (e.g., `vmbr0`)
- Terraform `>= 1.5`
- Access to your Proxmox API (`https://<your-pve-ip>:8006/`)
- Basic knowledge of Kubernetes and Talos concepts

---

## 🔧 How to Deploy

1. Clone the repository:
    ```bash
    git clone https://github.com/SerhiiMyronets/homelab.git
    cd homelab/terraform/cluster
    ```

2. Adjust Proxmox credentials in `variables.tf` or pass them as variables/environment variables.

3. Initialize Terraform:
    ```bash
    terraform init
    ```

4. Apply the configuration:
    ```bash
    terraform apply
    ```

5. Wait for your Kubernetes cluster to bootstrap.  
   After Talos nodes are up and Cilium is deployed, you can install ArgoCD, monitoring, ingress controllers, and other components.

---

## 📜 Notes

- Cilium is installed in a **minimal configuration** — only what is necessary for Kubernetes networking to function without kube-proxy.
- LoadBalancer IP management (`CiliumLoadBalancerIPPool`) and advanced features like Hubble UI are deferred to the **GitOps phase** with ArgoCD.
- Talos extensions such as DRBD and qemu-guest-agent are prepared but optional.

---

## 🎯 Future Plans

- Install and configure ArgoCD for GitOps management
- Deploy monitoring stack (Prometheus, Grafana, Loki)
- Setup cert-manager and ingress-nginx
- Integrate storage layer with Longhorn or Rook Ceph
