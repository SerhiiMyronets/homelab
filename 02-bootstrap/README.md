# 02-bootstrap

This stage installs essential platform components into the Kubernetes cluster using Helmfile.

It assumes that the cluster is already initialized and accessible using the generated `kubeconfig` and `talosconfig` from the previous stage (`01-infrastructure`).

## Purpose

The components installed in this phase are required for certificate management, ingress routing, GitOps-based application delivery, persistent storage, and cluster metrics.

## Installed Components

| Name             | Purpose                                        |
| ---------------- | ---------------------------------------------- |
| `metrics-server` | Enables resource metrics collection            |
| `cert-manager`   | Manages TLS certificates via Kubernetes CRDs   |
| `ingress-nginx`  | Provides ingress routing via NGINX controller  |
| `argo-cd`        | GitOps controller for managing Kubernetes apps |
| `longhorn`       | Provides persistent storage for workloads      |

## Usage

Before running this stage, make sure you have:

* Access to the cluster via `kubeconfig`
* Talos nodes fully bootstrapped and ready
* Helmfile and Helm installed on your machine

To apply the bootstrap components:

```bash
helmfile apply
```

This command will install all defined charts in the correct namespaces with the specified configurations.

## Notes

* Argo CD is configured with `--disable-auth` to simplify local testing
* cert-manager installs its own CRDs via values override

## Next steps

* [← Back to 01-infrastructure](../01-infrastructure/README.md)
* [→ Continue to 03-gitops](../03-gitops/README.md)
