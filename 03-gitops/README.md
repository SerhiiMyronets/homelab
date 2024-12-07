# 03-gitops

This stage enables full GitOps-driven management of the Kubernetes cluster using Argo CD. All components—including platform tools, observability stack, and demo applications—are defined as Argo CD Applications and managed declaratively.

## Purpose

* Define Argo CD Applications declaratively using `applications/*.yaml`
* Organize infrastructure and workloads by domain (platform, monitoring, demo)
* Synchronize services automatically via Argo CD

## Structure

* `applications/` – Argo CD Application manifests to bootstrap each logical layer:

    * `01-platform-bootstrap.yaml`
    * `02-monitoring-bootstrap.yaml`
    * `03-otel-demo.yaml`
    * `04-online-boutique-demo.yaml`

* `apps/` – Kustomize-based app definitions:

    * `01-platform/` – `argocd`, `cert-manager`, `cilium`, `longhorn`
    * `02-monitoring/` – `kube-prometheus-stack`, `tempo`, `loki`, `otel-collector`, `jaeger`, `hubble`
    * `03-demo/` – `otel-demo`, `online-boutique`

## Ingress Access

All Ingress resources created in this stage are configured to work with the NGINX Ingress Controller.
They receive static IPs from the Cilium LoadBalancer IP pool. By default, services are exposed via `192.168.100.80`.

TLS configuration blocks are included in the manifests but commented out. You can enable them if you want to secure access with HTTPS.

To make Ingress hosts resolvable, you can:

* Update your local `/etc/hosts` file (example below):

```bash
192.168.100.80  argocd.cluster hubble.cluster longhorn.cluster alertmanager.cluster grafana.cluster \
                jaeger.cluster loki.cluster prometheus.cluster tempo.cluster \
                otel-demo.cluster otel-demo-loadgen.cluster
```

* Or configure wildcard DNS entries (e.g., `*.homelab.local`) pointing to the Ingress IP.

## Usage

It is recommended to apply the Argo CD Applications in order, as each layer builds upon the previous one.

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

## Next steps

* [← Back to 02-bootstrap](../02-bootstrap/README.md)
