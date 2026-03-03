
output "id" {
  value       = azurerm_virtual_machine.this.id
  description = "ID of the managed resource"
}

output "private_ip_address" {
  value       = azurerm_network_interface.this.ip_configuration[0].private_ip_address
  description = "Primary private ip address"
}

output "identity_principal_id" {
  value       = azurerm_virtual_machine.this.identity[0].principal_id
  description = "Principal ID of the VM managed identity"
}
