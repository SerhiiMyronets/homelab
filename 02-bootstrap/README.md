# 02-bootstrap

This stage installs essential platform components into the Kubernetes cluster using Helmfile.

It assumes that the cluster is already initialized and accessible using the generated `kubeconfig` from the previous stage (`01-infrastructure`).

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
* Talos cluster is fully bootstrapped and reachable
* Helmfile and Helm installed on your machine

To apply the bootstrap components:

```bash
helmfile apply
```

This command installs all defined charts with their default or overridden configurations.

Note: After applying, it may take 1–2 minutes for Longhorn to become fully ready as it initializes its internal components.

You can check the status with:

```bash
kubectl get deployments -n longhorn-system
```

Example output when ready:

```
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
csi-attacher               3/3     3            3           2m13s
csi-provisioner            3/3     3            3           2m12s
csi-resizer                3/3     3            3           2m12s
csi-snapshotter            3/3     3            3           2m12s
longhorn-driver-deployer   1/1     1            1           3m21s
longhorn-ui                2/2     2            2           3m21s
```

## Navigation

[← Back to 01-infrastructure](../01-infrastructure/README.md) • [→ Continue to 03-gitops](../03-gitops/README.md)
