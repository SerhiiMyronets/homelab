// ==============================================================================
// Talos Client Configuration Output
// ==============================================================================

output "talosconfig" {
  description = <<-EOT
    Talos client configuration (talosconfig) in raw format.
    Save it locally by running:
      terraform output -raw talosconfig > ~/.talos/config
  EOT
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

// ==============================================================================
// Kubernetes Kubeconfig Output
// ==============================================================================

output "kubeconfig" {
  description = <<-EOT
    Kubernetes kubeconfig for accessing the cluster.
    Save it locally by running:
      terraform output -raw kubeconfig > ~/.kube/config
  EOT
  value     = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}
