# 03-gitops

In this stage, your Kubernetes cluster becomes fully GitOps-driven with automated deployment of platform services, observability stack, and demo workloads.
Through Argo CD, all components—including platform services, observability tools, and workloads—are deployed in a declarative and reproducible manner.

## Purpose

This layer turns your cluster into a fully GitOps-managed platform, enabling reproducible deployments, real-time observability, and traceable demo applications.

Argo CD Applications are bootstrapped in a controlled order to ensure service readiness and interdependency handling. This approach enables reproducible, declarative deployment of all Kubernetes workloads via Git.

## Structure

| Layer         | Path                  | Description                                    |
| ------------- | --------------------- | ---------------------------------------------- |
| Applications  | `applications/`       | Argo CD Application definitions (per stage)    |
| Platform Apps | `apps/01-platform/`   | Argo CD, cert-manager, Cilium, Longhorn        |
| Monitoring    | `apps/02-monitoring/` | Prometheus, Grafana, Tempo, Loki, Jaeger, etc. |
| Demo          | `apps/03-demo/`       | OpenTelemetry Demo (`otel-demo`)               |

## Ingress Access

All Ingress resources created in this stage are configured to work with the NGINX Ingress Controller.
They receive static IPs from the Cilium LoadBalancer IP pool. By default, services are exposed via `192.168.100.80`.

TLS configuration blocks are included in the manifests but commented out. To enable TLS for Ingress resources, uncomment the relevant sections in the Ingress manifests. Then, download the self-signed certificate and add it to your local trust store (e.g., macOS Keychain):

```bash
./03-gitops/scripts/extract-root-cert.sh
```

This script checks the `ca.crt` field in the `ingress-tls` secret under the `cert-manager` namespace.
If not found, it falls back to `tls.crt`. The output is saved to `local-cluster-root-ca.crt`.

You can then add this certificate to your system trust store:

* **macOS**: open Keychain Access → drag the file into "System" → set trust to "Always Trust"
* **Linux**: copy to `/usr/local/share/ca-certificates/` and run `sudo update-ca-certificates`.

To access services via domain names, you can:

* Update your local `/etc/hosts` file (example below):

```bash
192.168.100.80  argocd.homelab.local grafana.homelab.local prometheus.homelab.local \
                alertmanager.homelab.local loki.homelab.local tempo.homelab.local \
                jaeger.homelab.local longhorn.homelab.local \
                otel-demo.homelab.local otel-demo-loadgen.homelab.local
```

* Or configure wildcard DNS entries (e.g., \*.homelab.local) pointing to the Ingress IP.

## Usage

> **Pre-requisite**: Ensure Argo CD is already running in your cluster. It was installed via Helm in the previous stage (`02-bootstrap`).

It is recommended to apply the Argo CD Applications in order, as each layer builds upon the previous one (e.g., monitoring components depend on platform services such as cert-manager and ingress).

### Step-by-step deployment

```bash
# 1. Apply platform components
kubectl apply -f applications/01-platform-bootstrap.yaml

# 2. Apply observability stack
kubectl apply -f applications/02-monitoring-bootstrap.yaml

# 3. Apply the OpenTelemetry demo
kubectl apply -f applications/03-otel-demo.yaml
```

### Application breakdown

* `01-platform-bootstrap.yaml`

  * Adds Cilium to Argo CD management (already pre-installed)
  * Installs cert-manager with self-signed CA
  * Deploys Ingress resources for Argo CD and Longhorn UIs

* `02-monitoring-bootstrap.yaml`

  * Installs kube-prometheus-stack, OpenTelemetry Collector, Loki, Tempo, Jaeger, and Hubble
  * Deploys Ingress resources for Hubble, Jaeger, Alertmanager, Grafana, Prometheus, Loki, and Tempo

* `03-otel-demo.yaml`

  * Deploys the `otel-demo`, an OpenTelemetry example application representing a 21-microservice online store
  * Exposes the frontend and load generator via Ingress resources

After applying all stages, you’ll have a fully observable, GitOps-driven cluster with traceable demo workloads ready for exploration.

## UI Previews

Below are sample screenshots of key components that become available after deploying this layer. All of them are exposed via Ingress with optional TLS.

### Lens

Cluster workloads and sync events visualized in Lens — a Kubernetes dashboard for developers and operators.

<img src="../assets/lens.png" width="1100"/>

### Argo CD

Argo CD web interface showing synced applications and their health/status.

<img src="../assets/argocd.png" width="1100"/>

### Grafana

Observability dashboards with real-time service-level metrics and performance data.

<img src="../assets/grafana.png" width="1100"/>

### Longhorn

Web UI displaying storage volumes, replicas, and system health status.

<img src="../assets/longhorn.png" width="1100"/>

### Hubble

Cilium-powered service map visualizing real-time network traffic flows.

<img src="../assets/hubble.png" width="1100"/>

### Jaeger

UI for exploring distributed traces captured by the OpenTelemetry instrumentation.

<img src="../assets/jaeger.png" width="1100"/>

### Tempo

Trace timeline visualization inside Grafana using the Tempo datasource.

<img src="../assets/tempo.png" width="1100"/>

### OpenTelemetry Demo

The main frontend page of the otel-demo microservices-based e-commerce application.

<img src="../assets/otel-demo.png" width="1100"/>

### Load Generator

Locust UI that generates synthetic traffic to simulate real user behavior.

<img src="../assets/load-gen.png" width="1100"/>

All components shown above are deployed declaratively and updated automatically via Argo CD.

## Navigation

[← 02-bootstrap](../02-bootstrap/README.md) • [↑ Main project README](../README.md)
