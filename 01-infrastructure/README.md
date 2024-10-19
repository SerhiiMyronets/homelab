# 01-infrastructure

This stage provisions the base infrastructure for the Kubernetes cluster using Talos Linux and Terraform on a Proxmox VE host.

It creates control plane and worker node virtual machines, injects machine configurations, and applies environment-specific patches to customize Talos behavior.

## Purpose

* Provision VMs on Proxmox with static IPs
* Generate and inject Talos machine configurations
* Apply Talos patches for control plane, workers, and Cilium mode
* Output all required data for the bootstrap phase

## Files

* `providers.tf` – defines Terraform providers
* `proxmox_nodes.tf` – VM resource definitions
* `talos_configs.tf` – generation and injection of Talos machine configs
* `variables.tf` – input variables
* `terraform.tfvars` – example configuration
* `outputs.tf` – exposed outputs (e.g., IPs, config paths)
* `patches/` – Talos machine config patches grouped by role or function

## Usage

1. Before applying Terraform, provide your Proxmox connection details (endpoint, username, password, and node name) in `terraform.tfvars`.

2. Optional cluster settings such as Talos version, VM resources, and network configuration are defined in `variables.tf` and can be overridden as needed.

3. Initialize and apply the configuration:

```bash
terraform init
terraform apply
```

Terraform will provision the VMs, generate Talos configurations, and return the required outputs for the next deployment stage.

This stage provides the following outputs:

* `talosconfig` – Talos client configuration in raw format
* `kubeconfig` – Kubernetes kubeconfig used to access the cluster
* `talosconfig_command` – shell command to save Talos config locally
* `kubeconfig_command` – shell command to save kubeconfig locally

These outputs are used in the next stage (`02-bootstrap`) to initialize and interact with the Talos-based cluster.

**Next steps:**

* [← Back to 00-prerequisite](../00-prerequisite/README.md)
* [→ Continue to 02-bootstrap](../02-bootstrap/README.md)
