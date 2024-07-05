// ==============================================================================
// Talos Client Configuration Output
// ==============================================================================

output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig_command" {
  value = "terraform output -raw kubeconfig > ~/.kube/config"
}

// ==============================================================================
// Kubernetes Kubeconfig Output
// ==============================================================================

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}

output "talosconfig_command" {
  value = "terraform output -raw talosconfig > ~/.talos/config"
}
