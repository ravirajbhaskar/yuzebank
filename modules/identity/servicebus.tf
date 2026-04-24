resource "azurerm_servicebus_namespace" "sb_namespace" {
  for_each = var.servicebus_namespaces

  name                = "${each.value.resource_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${var.random_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.identity_rg.name

  sku      = each.value.sku
  capacity = each.value.capacity

  tags = each.value.tags
}

resource "azurerm_servicebus_queue" "sb_queue" {
  for_each = var.servicebus_queues

  name         = "${each.value.resource_prefix}-${each.value.client_name}-${each.value.environment}-${each.value.location_code}"
  namespace_id = azurerm_servicebus_namespace.sb_namespace[each.value.namespace_key].id

  max_size_in_megabytes = each.value.max_size_in_megabytes
}
