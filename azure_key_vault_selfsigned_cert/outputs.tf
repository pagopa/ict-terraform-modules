
output "name" {
  value       = azurerm_key_vault_certificate.this.name
  description = "Name of the self-signed certificate"
}

output "versionless_secret_id" {
  value       = azurerm_key_vault_certificate.this.versionless_secret_id
  description = "Versionless secret id of the self-signed certificate"
}

output "secret_id" {
  value       = azurerm_key_vault_certificate.this.secret_id
  description = "Secret id of the self-signed certificate"
}
