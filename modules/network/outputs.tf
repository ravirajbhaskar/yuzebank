output "vnet_rg_name" {
  value = azurerm_resource_group.vnet_rg.name
}

# Networking
output "vnet_ids" {
  value = { for k, v in azurerm_virtual_network.vnet : k => v.id }
}
output "subnet_ids" {
  value = { for k, v in azurerm_subnet.subnet : k => v.id }
}

# Application Gateway
output "application_gateway_ids" {
  value = { for k, v in azurerm_application_gateway.this : k => v.id }
}

output "application_gateway_names" {
  value = { for k, v in azurerm_application_gateway.this : k => v.name }
}

output "application_gateway_public_ips" {
  value = { for k, v in azurerm_application_gateway.this : k => v.frontend_ip_configuration[0].private_ip_address }
}

# NSG outputs
output "nsg_ids" {
  value       = { for k, v in azurerm_network_security_group.nsg : k => v.id }
  description = "The IDs of all Network Security Groups"
}