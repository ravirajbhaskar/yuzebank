resource "azurerm_notification_hub_namespace" "nh_namespace" {
  for_each = var.notification_hub_namespaces

  # Dynamic naming: ntfns-{key}-{client_name}-{environment}-{location_code}
  name                = "ntfns-${each.key}-${var.client_name}-${var.environment}-${var.location_code}"
  location            = var.location
  resource_group_name = azurerm_resource_group.monitor_rg.name

  sku_name       = each.value.sku_name
  namespace_type = each.value.namespace_type

  tags = merge(var.common_tags, each.value.tags)
  # Ignore tag-only changes
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_notification_hub" "nh" {
  for_each = var.notification_hubs

  # Dynamic naming: ntfh-{key}-{client_name}-{environment}-{location_code}
  name                = "ntfh-${each.key}-${var.client_name}-${var.environment}-${var.location_code}"
  location            = var.location
  resource_group_name = azurerm_resource_group.monitor_rg.name

  namespace_name = azurerm_notification_hub_namespace.nh_namespace[each.value.namespace_key].name

  tags = merge(var.common_tags, each.value.tags)
  # Ignore tag-only changes
  lifecycle {
    ignore_changes = [tags]
  }
}
