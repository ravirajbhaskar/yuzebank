# Azure Cloud Shell infrastructure
resource "azurerm_resource_group" "cloudshell_rg" {
  name     = "rg-cloudshell-${var.client_name}-${var.environment}-${var.location_code}"
  location = var.location
  tags     = var.common_tags
}

# Virtual Network for Cloud Shell
resource "azurerm_virtual_network" "cloudshell_vnet" {
  name                = "vnet-cloudshell-${var.client_name}-${var.environment}-${var.location_code}"
  location            = azurerm_resource_group.cloudshell_rg.location
  resource_group_name = azurerm_resource_group.cloudshell_rg.name
  address_space       = ["10.124.0.0/16"]
  tags                = var.common_tags
}

# Subnet for Cloud Shell containers
resource "azurerm_subnet" "containers" {
  name                 = "cloudshell-containers-${var.client_name}-${var.environment}"
  resource_group_name  = azurerm_resource_group.cloudshell_rg.name
  virtual_network_name = azurerm_virtual_network.cloudshell_vnet.name
  address_prefixes     = ["10.124.1.0/24"]

  delegation {
    name = "cloudshell-delegation"

    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
    }
  }

  service_endpoints = ["Microsoft.Storage"]
}

# Subnet for Azure Relay
resource "azurerm_subnet" "relay" {
  name                 = "relay${var.client_name}${var.environment}${var.location_code}"
  resource_group_name  = azurerm_resource_group.cloudshell_rg.name
  virtual_network_name = azurerm_virtual_network.cloudshell_vnet.name
  address_prefixes     = ["10.124.2.0/24"]
}

# Azure Relay namespace
resource "azurerm_relay_namespace" "relay" {
  name                = "cloudshell-relay-${var.client_name}-${var.environment}-${var.location_code}-${var.random_suffix}"
  location            = azurerm_resource_group.cloudshell_rg.location
  resource_group_name = azurerm_resource_group.cloudshell_rg.name
  sku_name            = "Standard"
  tags                = var.common_tags
}

# Private endpoint for Azure Relay
resource "azurerm_private_endpoint" "relay_endpoint" {
  name                = "cloudshell-relay-endpoint-${var.client_name}-${var.environment}-${var.location_code}"
  location            = azurerm_resource_group.cloudshell_rg.location
  resource_group_name = azurerm_resource_group.cloudshell_rg.name
  subnet_id           = azurerm_subnet.relay.id

  private_service_connection {
    name                           = "relay-connection-${var.environment}-${var.location_code}"
    private_connection_resource_id = azurerm_relay_namespace.relay.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  tags = var.common_tags
}

# Private DNS zone for Relay
resource "azurerm_private_dns_zone" "relay_dns" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.cloudshell_rg.name
  tags                = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "relay_link" {
  name                  = "relay-dns-link-${var.environment}-${var.location_code}"
  resource_group_name   = azurerm_resource_group.cloudshell_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.relay_dns.name
  virtual_network_id    = azurerm_virtual_network.cloudshell_vnet.id
  tags                  = var.common_tags
}

resource "azurerm_private_dns_a_record" "relay_record" {
  name                = azurerm_relay_namespace.relay.name
  zone_name           = azurerm_private_dns_zone.relay_dns.name
  resource_group_name = azurerm_resource_group.cloudshell_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.relay_endpoint.private_service_connection[0].private_ip_address]
  tags                = var.common_tags
}

# Storage account for Cloud Shell persistent storage
resource "azurerm_storage_account" "cloudshell" {
  name                     = "cshell${var.client_name}${var.environment}${var.location_code}${var.random_suffix}"
  resource_group_name      = azurerm_resource_group.cloudshell_rg.name
  location                 = azurerm_resource_group.cloudshell_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.common_tags
}

resource "azurerm_storage_share" "cloudshell_share" {
  name               = "cloudshellprofile${var.client_name}${var.environment}${var.location_code}"
  storage_account_id = azurerm_storage_account.cloudshell.id
  quota              = 6
}

resource "azurerm_storage_account_network_rules" "cloudshell_sa_rules" {
  storage_account_id         = azurerm_storage_account.cloudshell.id
  default_action             = "Deny"
  virtual_network_subnet_ids = [azurerm_subnet.containers.id]

  depends_on = [azurerm_storage_share.cloudshell_share]
}

# Network profile for Cloud Shell container
resource "azurerm_network_profile" "cloudshell_profile" {
  name                = "cloudshell-netprofile-${var.client_name}-${var.environment}-${var.location_code}-${var.random_suffix}"
  location            = azurerm_resource_group.cloudshell_rg.location
  resource_group_name = azurerm_resource_group.cloudshell_rg.name

  container_network_interface {
    name = "cloudshell-ni-${var.environment}-${var.location_code}"

    ip_configuration {
      name      = "ipconfig1"
      subnet_id = azurerm_subnet.containers.id
    }
  }

  tags = var.common_tags
}

# ACI service principal for role assignments
data "azuread_service_principal" "aci" {
  display_name = "Azure Container Instance Service"
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = azurerm_network_profile.cloudshell_profile.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.aci.object_id

  depends_on = [
    azurerm_network_profile.cloudshell_profile
  ]
}

resource "azurerm_role_assignment" "relay_contributor" {
  scope                = azurerm_relay_namespace.relay.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.aci.object_id

  depends_on = [
    azurerm_relay_namespace.relay
  ]
}
