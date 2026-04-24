# Resource group for compute resources
resource "azurerm_resource_group" "app_rg" {
  name     = "${var.rg_prefix}-app-${var.client_name}-${var.environment}-${var.location_code}"
  location = var.location
  tags     = var.common_tags
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  for_each = var.acr_registries

  name                = "${each.value.resource_prefix}${var.client_name}${var.environment}${var.location_code}${var.random_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name

  sku           = each.value.sku           # "Standard"
  admin_enabled = each.value.admin_enabled # true or false

  dynamic "georeplications" {
    for_each = each.value.georeplications
    content {
      location = georeplications.value
    }
  }

  public_network_access_enabled = each.value.public_network_access_enabled
  zone_redundancy_enabled       = each.value.zone_redundancy_enabled

  tags = var.common_tags
}
