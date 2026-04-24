# Resource group for monitoring
resource "azurerm_resource_group" "monitor_rg" {
  name     = "${var.rg_prefix}-monitor-${var.client_name}-${var.environment}-${var.location_code}"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_application_insights" "appinsights" {
  for_each = var.application_insights

  # Dynamic naming convention
  name                = "appi-${each.key}-${var.client_name}-${var.environment}-${var.location_code}"
  location            = var.location
  resource_group_name = azurerm_resource_group.monitor_rg.name

  application_type = each.value.application_type

  # Optional: if you're using workspace-based App Insights
  workspace_id = each.value.workspace_id

  retention_in_days = each.value.retention_in_days
  tags              = merge(var.common_tags, each.value.tags)
  # Ignore tag-only changes to avoid unnecessary resource updates
  lifecycle {
    ignore_changes = [tags]
  }
}
