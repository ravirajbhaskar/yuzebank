# Resource group for Event Hub
resource "azurerm_resource_group" "eventhub_rg" {
  name     = "${var.rg_prefix}-eventhub-${var.client_name}-${var.environment}-${var.location_code}"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_eventhub_namespace" "ehns" {
  for_each            = var.eventhub_namespaces
  name                = "${each.value.resource_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-${var.random_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.eventhub_rg.name
  sku                 = each.value.sku
  capacity            = each.value.capacity
  tags                = var.common_tags
}

resource "azurerm_eventhub" "eh" {
  for_each          = var.eventhubs
  name              = "${each.value.resource_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}"
  namespace_id      = azurerm_eventhub_namespace.ehns[each.value.namespace_key].id
  partition_count   = each.value.partition_count
  message_retention = each.value.message_retention
}