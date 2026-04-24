# Network Security Groups
# Create NSGs dynamically for each subnet
resource "azurerm_network_security_group" "nsg" {
  for_each            = toset(var.nsg_subnets)
  name                = "${var.nsg_prefix}-${each.value}-${var.client_name}-${var.environment}-${var.location_code}"
  location            = var.location
  resource_group_name = azurerm_resource_group.vnet_rg.name

  dynamic "security_rule" {
    for_each = lookup(var.nsg_rules, each.value, { rules = [] }).rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = var.common_tags
}

# Associate NSGs with subnets dynamically
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each                  = toset(var.nsg_subnets)
  subnet_id                 = azurerm_subnet.subnet["${var.vnet_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${var.subnet_prefix}-${each.value}-${var.client_name}-${var.environment}-${var.location_code}"].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value].id
}