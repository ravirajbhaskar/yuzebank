# Essential Resource IDs for cross-module references
output "notification_hub_namespace_ids" {
  value       = { for k, v in azurerm_notification_hub_namespace.nh_namespace : k => v.id }
  description = "Map of notification hub namespace IDs."
}

output "notification_hub_ids" {
  value       = { for k, v in azurerm_notification_hub.nh : k => v.id }
  description = "Map of notification hub IDs."
}

output "application_insights_ids" {
  value       = { for k, v in azurerm_application_insights.appinsights : k => v.id }
  description = "Map of Application Insights IDs."
}

output "log_analytics_workspace_ids" {
  value       = { for k, v in azurerm_log_analytics_workspace.law : k => v.id }
  description = "Map of Log Analytics Workspace IDs."
}

# Resource Groups for cross-module reference
output "notification_rg_names" {
  value       = azurerm_resource_group.monitor_rg.name
  description = "Monitoring resource group name."
}
