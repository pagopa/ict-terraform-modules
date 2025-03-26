
output "private_ip" {
  description = "Private IP of the private endpoint"
  value       = azurerm_private_endpoint.this.private_service_connection[0].private_ip_address
}
