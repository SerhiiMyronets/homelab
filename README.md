# My Homelab project

This is my homelab project with talos linux and proxmox. The goal is to have a homelab with a few VMs and containers running on it.

## 🚀 Proxmox setup
- network setup /proxmox/interfaces > /etc/network/interfaces

## Traefik setup

helm upgrade --install traefik traefik/traefik \
--namespace traefik \
--set service.type=LoadBalancer \
--set service.loadBalancerIP="10.1.1.240" \
--set ports.web.port=80 \
--set ports.websecure.port=443 \
--set service.spec.allocateLoadBalancerNodePorts=false