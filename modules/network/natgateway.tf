# NAT Gateway for private AKS cluster
# Public IP for NAT Gateway
resource "azurerm_public_ip" "aks_nat_pip" {
  name                = "pip-aks-nat-${var.client_name}-${var.environment}-${var.location_code}"
  location            = var.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.common_tags
  # Ignore tag-only changes so small metadata updates won't force changes
  lifecycle {
    ignore_changes = [tags]
  }
}

# Public IP Prefix for NAT Gateway (/31 = 2 IPs)
resource "azurerm_public_ip_prefix" "aks_nat_prefix" {
  name                = "ippre-aks-nat-${var.client_name}-${var.environment}-${var.location_code}"
  location            = var.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  prefix_length       = 31
  sku                 = "Standard"

  tags = var.common_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# NAT Gateway
resource "azurerm_nat_gateway" "aks_nat" {
  name                    = "nat-${var.client_name}-${var.environment}-${var.location_code}"
  location                = var.location
  resource_group_name     = azurerm_resource_group.vnet_rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4

  tags = var.common_tags
  lifecycle {
    ignore_changes = [tags]
  }
}

# Associate Public IP with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "nat_pip_association" {
  nat_gateway_id       = azurerm_nat_gateway.aks_nat.id
  public_ip_address_id = azurerm_public_ip.aks_nat_pip.id
}

# Associate Public IP Prefix with NAT Gateway
resource "azurerm_nat_gateway_public_ip_prefix_association" "nat_prefix_association" {
  nat_gateway_id      = azurerm_nat_gateway.aks_nat.id
  public_ip_prefix_id = azurerm_public_ip_prefix.aks_nat_prefix.id
}

# Associate NAT Gateway with AKS Subnet
resource "azurerm_subnet_nat_gateway_association" "aks_subnet_nat" {
  subnet_id      = azurerm_subnet.subnet["${var.vnet_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${var.subnet_prefix}-aks-${var.client_name}-${var.environment}-${var.location_code}"].id
  nat_gateway_id = azurerm_nat_gateway.aks_nat.id
}
