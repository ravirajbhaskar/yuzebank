# Peering from CloudShell VNet to Main VNet
resource "azurerm_virtual_network_peering" "cloudshell_to_main" {
  name                      = "peer-cloudshell-to-main-${var.client_name}-${var.environment}-${var.location_code}"
  resource_group_name       = azurerm_resource_group.cloudshell_rg.name
  virtual_network_name      = azurerm_virtual_network.cloudshell_vnet.name
  remote_virtual_network_id = var.main_vnet_id

  # Allow forwarded traffic from main VNet
  allow_forwarded_traffic = true

  # Allow gateway transit (if main VNet has a VPN/ExpressRoute gateway)
  allow_gateway_transit = false

  # Use remote gateways (if main VNet has a gateway)
  use_remote_gateways = false

  # Allow virtual network access
  allow_virtual_network_access = true
}

# Peering from Main VNet to CloudShell VNet
resource "azurerm_virtual_network_peering" "main_to_cloudshell" {
  name                      = "peer-main-to-cloudshell-${var.client_name}-${var.environment}-${var.location_code}"
  resource_group_name       = var.vnet_rg_name
  virtual_network_name      = "${var.vnet_prefix}-${var.client_name}-${var.environment}-${var.location_code}"
  remote_virtual_network_id = azurerm_virtual_network.cloudshell_vnet.id

  # Allow forwarded traffic from CloudShell VNet
  allow_forwarded_traffic = true

  # Allow gateway transit (if this VNet has a VPN/ExpressRoute gateway)
  allow_gateway_transit = false

  # Use remote gateways
  use_remote_gateways = false

  # Allow virtual network access
  allow_virtual_network_access = true

  # Explicit dependency: Wait for CloudShell VNet to finish provisioning
  depends_on = [azurerm_virtual_network.cloudshell_vnet]
}
