resource "azurerm_log_analytics_workspace" "law" {
  for_each = var.log_analytics_workspaces

  # Dynamic naming: log-{key}-{client_name}-{environment}-{location_code}
  name                = "log-${each.key}-${var.client_name}-${var.environment}-${var.location_code}"
  location            = var.location
  resource_group_name = azurerm_resource_group.monitor_rg.name
  sku                 = each.value.sku
  retention_in_days   = each.value.retention_in_days
  tags                = merge(var.common_tags, each.value.tags)
  # Ignore tag-only changes
  lifecycle {
    ignore_changes = [tags]
  }
}
