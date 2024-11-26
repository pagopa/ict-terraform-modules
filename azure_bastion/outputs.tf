output "id" {
  value       = azurerm_bastion_host.this.id
  description = "ID of the managed resource"
}

output "public_ip_address" {
  value       = var.public_ip_id == null ? azurerm_public_ip.bastion[0].ip_address : null
  description = "Public IP address of the Bastion, if NOT externally provided"
}
