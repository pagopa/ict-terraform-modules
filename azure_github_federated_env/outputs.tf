
output "principal_id" {
  description = "Principal id of the managed identity federated with GitHub environment"
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "environment" {
  description = "GitHub environment"
  value       = github_repository_environment.this.environment
}
