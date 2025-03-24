# 🏡 Homelab Kubernetes Cluster with Talos, Terraform, and Proxmox

This project sets up a fully automated Kubernetes cluster tailored for homelab environments. It leverages:

* **Talos Linux** — a secure, immutable Kubernetes OS
* **Terraform** — Infrastructure as Code (IaC) for reproducible deployments
* **Proxmox VE** — as the virtualization platform
* **Cilium** — an eBPF-based CNI replacing kube-proxy
* **Helm, Kustomize, and ArgoCD** — for declarative app and infra management

---

## 🔍 Why this structure?

```plaintext
homelab/
├── 01-infra/                 # Terraform code: Proxmox VMs, Talos config, patches
│   ├── locals.tf             # Local values used in the Terraform module
│   ├── outputs.tf            # Output definitions for Terraform
│   ├── providers.tf          # Terraform provider declarations
│   ├── proxmox_nodes.tf      # Proxmox VM resource definitions
│   ├── talos_configs.tf      # Talos config generation and machine patches
│   ├── variables.tf          # Input variables for customization
│   └── patches/              # Talos machine configuration patches
│       ├── common/           # Shared patches for all nodes
│       ├── controller/       # Controller-specific patches (VIP, Cilium, etc.)
│       └── worker/           # Worker-specific patches (Longhorn disk)
├── 02-bootstrap/            # Helmfile-based bootstrapping of core services
│   └── helmfile.yaml        # Defines cert-manager, nginx, argocd, longhorn
├── 03-gitops/               # GitOps-managed app manifests via ArgoCD + Kustomize
│   ├── applications/        # ArgoCD Application CRDs
│   └── apps/                # App directories (argocd-ingress, cert-bootstrap, etc.)
├── extract-root-cert.sh     # Script to extract Talos root certificate
├── .gitignore
└── README.md
```

The project is split into 3 main layers for clarity and modularity:

### `01-infra/` — Infrastructure Layer

Contains all Terraform code for provisioning virtual machines on Proxmox, generating Talos configurations, and injecting patches.

* `patches/common/` — shared Talos patches (e.g., KubePrism, HostDNS, Discovery)
* `patches/controller/` — patches for controller nodes (e.g., VIP, Cilium, LB manifest)
* `patches/worker/` — patches for workers (e.g., Longhorn disk mounting)

This separation allows more control over Talos behavior per node role.

### `02-bootstrap/` — Bootstrap Layer

Contains `helmfile.yaml` to bootstrap core components before GitOps takes over:

* `cert-manager` — TLS certificate management
* `ingress-nginx` — basic ingress controller
* `argo-cd` — GitOps tool for syncing Kubernetes manifests
* `longhorn` — persistent storage solution

### `03-gitops/` — GitOps Layer

Defines all ArgoCD applications and Kustomize overlays:

* `applications/` — ArgoCD Application CRDs
* `apps/` — actual app manifests structured by name:

    * `argocd-ingress/`
    * `cert-bootstrap/` (self-signed CA issuer setup)
    * `longhorn-ingress/`

This layout supports progressive GitOps and makes onboarding additional apps straightforward.

---

## 🌐 Networking

* VLAN: `10.1.1.0/24`
* VIP: defined via Talos `controller` patches
* Cilium handles all east-west and north-south traffic (no kube-proxy)

---

## ⚙️ How to Use

### 1. Customize variables

Adjust the Terraform variables and Talos patches to match your homelab hardware and desired settings.

### 2. Apply infrastructure

```bash
cd 01-infra
terraform init
terraform apply
```

This will:

* Create Proxmox VMs
* Generate Talos configs
* Apply machine config patches

### 3. Bootstrap Helm dependencies

```bash
cd 02-bootstrap
helmfile apply
```

This will install:

* `cert-manager`
* `ingress-nginx`
* `argo-cd`
* `longhorn`

### 4. Deploy GitOps layer

Use `argocd` or CLI to sync the `03-gitops/applications`.

---

## 🎓 Motivation

This repo is built for:

* Home experimentation and platform engineering practice
* Testing Talos, GitOps, Cilium, and K8s internals in a safe isolated way
* Serving as a template for lightweight, secure self-hosted infrastructure

---

## 📖 Future Plans

* Add OpenTelemetry/Observability stack
* Automate backups (ETCD, Longhorn)
* HA ArgoCD with ApplicationSets
* FluxCD optional support

---

## 🙏 Credits

Created and maintained by [Serhii Myronets](https://github.com/SerhiiMyronets)

Inspired by Talos, Proxmox, ArgoCD, and Cilium communities.
