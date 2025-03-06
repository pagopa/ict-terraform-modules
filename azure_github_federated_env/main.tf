
# github environment

resource "github_repository_environment" "this" {
  environment         = var.github_environment
  repository          = var.github_repository
  prevent_self_review = false
  can_admins_bypass   = true
}

# managed identity
resource "azurerm_user_assigned_identity" "this" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# federate the managed identity with the github environment
resource "azurerm_federated_identity_credential" "this" {
  parent_id           = azurerm_user_assigned_identity.this.id
  resource_group_name = azurerm_user_assigned_identity.this.resource_group_name
  name                = "github-federated-ci"
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:${var.github_org}/${var.github_repository}:environment:${github_repository_environment.this.environment}"
}


# environment secrets to allow github to login to azure with federated credentials

resource "github_actions_environment_secret" "arm_tenant_id" {
  repository      = var.github_repository
  environment     = github_repository_environment.this.environment
  secret_name     = "ARM_TENANT_ID"
  plaintext_value = var.tenant_id
}

resource "github_actions_environment_secret" "arm_subscription_id" {
  repository      = var.github_repository
  environment     = github_repository_environment.this.environment
  secret_name     = "ARM_SUBSCRIPTION_ID"
  plaintext_value = var.subscription_id
}

resource "github_actions_environment_secret" "arm_client_id" {
  repository      = var.github_repository
  environment     = github_repository_environment.this.environment
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = azurerm_user_assigned_identity.this.client_id
}
