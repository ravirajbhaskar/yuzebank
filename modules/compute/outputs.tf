output "aks_ids" {
  value = { for k, v in azurerm_kubernetes_cluster.aks : k => v.id }
}

# Resource Group outputs - now references resource
output "app_rg_name" {
  value       = azurerm_resource_group.app_rg.name
  description = "The name of the app resource group."
}

output "app_rg_id" {
  value       = azurerm_resource_group.app_rg.id
  description = "The ID of the app resource group."
}

output "function_app_ids" {
  value = { for k, v in azurerm_linux_function_app.functions : k => v.id }
}

output "function_app_names" {
  value       = [for k, v in azurerm_linux_function_app.functions : v.name]
  description = "The names of the Azure Function Apps."
}

output "aks_resource_group_name" {
  value       = var.vnet_rg_name
  description = "The resource group name used for AKS clusters."
}

output "cloudshell_vnet_id" {
  value       = azurerm_virtual_network.cloudshell_vnet.id
  description = "The ID of the CloudShell virtual network."
}

output "cloudshell_storage_account_id" {
  value       = azurerm_storage_account.cloudshell.id
  description = "The ID of the Cloud Shell storage account."
}

output "cloudshell_relay_namespace_id" {
  value       = azurerm_relay_namespace.relay.id
  description = "The ID of the Cloud Shell relay namespace."
}

# ACR Outputs
output "acr_ids" {
  value       = { for k, v in azurerm_container_registry.acr : k => v.id }
  description = "The IDs of the Azure Container Registries."
}

output "acr_login_servers" {
  value       = { for k, v in azurerm_container_registry.acr : k => v.login_server }
  description = "The login server URLs for the Azure Container Registries."
}

