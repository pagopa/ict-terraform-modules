
output "id" {
  value       = azurerm_subnet.this.id
  description = "Id of the managed VM subnet"
}

output "address_prefixes" {
  value       = azurerm_subnet.this.address_prefixes
  description = "Address prefixes of the managed VM subnet"
}

output "network_security_group_id" {
  value       = azurerm_network_security_group.this.id
  description = "Id of the network security group attached to the subnet"
}

output "network_security_group_name" {
  value       = azurerm_network_security_group.this.name
  description = "Name of the network security group attached to the subnet"
}
