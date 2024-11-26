output "id" {
  value       = azurerm_linux_virtual_machine.this.id
  description = "ID of the managed resource"
}

output "private_ip_address" {
  value       = azurerm_linux_virtual_machine.this.private_ip_address
  description = "Primary private ip address"
}

output "ssh_private_key_pem" {
  value       = tls_private_key.ssh.private_key_pem
  description = "Exported for emergency cases, but Entra ID authentication should be used"
  sensitive   = true
}
