# Resource group for virtual network
resource "azurerm_resource_group" "vnet_rg" {
  name     = "${var.rg_prefix}-vnet-${var.client_name}-${var.environment}-${var.location_code}"
  location = var.location
  tags     = var.common_tags
}

locals {
  # Map of vnets keyed by dynamic name for easy lookup
  vnets_map = { for i, vnet in var.vnets : "${var.vnet_prefix}-${var.client_name}-${var.environment}-${var.location_code}" => vnet }

  subnets_map = {
    for subnet in flatten([
      for i, vnet in var.vnets : [
        for subnet in vnet.subnets : {
          vnet_dynamic_name = "${var.vnet_prefix}-${var.client_name}-${var.environment}-${var.location_code}"
          address_prefix    = subnet.address_prefix
          dynamic_name      = "${var.subnet_prefix}-${subnet.subnet_name}-${var.client_name}-${var.environment}-${var.location_code}"
          delegation        = subnet.delegation
        }
      ]
    ]) :
    "${subnet.vnet_dynamic_name}-${subnet.dynamic_name}" => {
      vnet_dynamic_name = subnet.vnet_dynamic_name
      address_prefixes  = [subnet.address_prefix]
      dynamic_name      = subnet.dynamic_name
      delegation        = subnet.delegation
    }
  }
}

# Create virtual networks

resource "azurerm_virtual_network" "vnet" {
  for_each            = local.vnets_map
  name                = each.key
  address_space       = each.value.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  tags                = var.common_tags
}

# Create subnets, with optional delegation for a specific subnet

resource "azurerm_subnet" "subnet" {
  for_each = local.subnets_map

  name                 = each.value.dynamic_name
  resource_group_name  = azurerm_resource_group.vnet_rg.name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_dynamic_name].name
  address_prefixes     = each.value.address_prefixes

  # Add service endpoints for CloudShell subnet to support storage account network rules
  service_endpoints = strcontains(each.value.dynamic_name, "cloudshell") ? ["Microsoft.Storage"] : []

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}