# 01-infrastructure

This stage provisions the base infrastructure for the Kubernetes cluster using Talos Linux and Terraform on a Proxmox VE host.

It creates control plane and worker node virtual machines, injects machine configurations, and applies environment-specific patches to customize Talos behavior.

## Purpose

* Provision VMs on Proxmox with static IPs
* Generate and inject Talos machine configurations
* Apply Talos patches for control plane, workers, and Cilium mode
* Output all required data for the bootstrap phase

## Directory Structure

* `providers.tf` – defines Terraform providers
* `proxmox_nodes.tf` – VM resource definitions
* `talos_configs.tf` – generation and injection of Talos machine configs
* `variables.tf` – input variables
* `terraform.tfvars` – example configuration
* `outputs.tf` – exposed outputs (e.g., IPs, config paths)
* `patches/` – Talos machine config patches grouped by role or function

## Usage

Before you begin, add your Proxmox connection details to `terraform.tfvars`.

Additional cluster settings such as Talos version, VM resources, and network configuration are defined in `variables.tf` and can be overridden if needed.

```bash
terraform init
terraform apply

# Save kubeconfig locally to access the cluster
terraform output -raw kubeconfig > ~/.kube/config
```

Terraform will provision the VMs, generate Talos configurations, and return the required outputs for the next deployment stage. Wait until all nodes become `Ready` before proceeding. You can verify this using:

```bash
kubectl get nodes
```

Expected output:

```
NAME                    STATUS   ROLES           AGE     VERSION
talos-controlplane-01   Ready    control-plane   3m24s   v1.32.0
talos-worker-01         Ready    <none>          3m8s    v1.32.0
```

**Next steps:**

* [← Back to 00-prerequisite](../00-prerequisite/README.md)
* [→ Continue to 02-bootstrap](../02-bootstrap/README.md)
