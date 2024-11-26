output "id" {
  value       = azurerm_firewall.this.id
  description = "ID of the managed resource"
}

output "policy_id" {
  value       = var.firewall_policy_id == null ? azurerm_firewall_policy.this[0].id : var.firewall_policy_id
  description = "ID of the firewall policy"
}

output "public_ip_addresses" {
  value       = azurerm_public_ip.firewall.ip_address
  description = "Public ip address of the firewall"
}

output "mgmt_public_ip_addresses" {
  value       = azurerm_public_ip.management.ip_address
  description = "Public ip address of the firewall management"
}
