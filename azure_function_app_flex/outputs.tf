output "id" {
  value       = azurerm_function_app_flex_consumption.this.id
  description = "ID of the function app"
}

output "identity_principal_id" {
  value       = azurerm_function_app_flex_consumption.this.identity[0].principal_id
  description = "Principal ID of the func managed identity"
}
