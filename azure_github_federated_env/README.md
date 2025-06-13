# Azure GitHub federated environment

Provision a GitHub environment for deploying AzureRM based workloads (for example, IaC with Terraform) with federated identity.

It creates:

* Azure managed identity
* GitHub environment
* Azure federated credentials of the identity allowing login from the GitHub environment 
* GitHub environment secrets for logging in with the federated credentials in that environment:
  * `ARM_TENANT_ID`. AzureRM tenant id
  * `ARM_SUBSCRIPTION_ID`. AzureRM subscription id
  * `ARM_CLIENT_ID`. AzureRM client id of the managed identity to use

## Example usage

Create GitHub environment and federated managed identity in Azure,
with permissions to run Terraform Apply targeting resources in
`my-target-rg` resource group:

```hcl
data "azurerm_resource_group" "target_rg" {
  name = "my-target-rg"
}

data "azurerm_resource_group" "identity" {
  name = "my-identity-rg"
}

data "azurerm_storage_account" "tfstate" {
  name                = "mystoragewithtfstate"
  resource_group_name = "terraform-state-rg"
}

module "core_cd_gh_federated_env" {
  source = "github.com/pagopa/ict-terraform-modules//azure_github_federated_env?ref=v1.8.0"

  identity_name       = "my-infra-core-cd-id"
  resource_group_name = data.azurerm_resource_group.identity.name
  location            = data.azurerm_resource_group.identity.location
  github_environment  = "prod-core-cd"
  github_org          = "myorg"
  github_repository   = "myrepo"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  subscription_id     = data.azurerm_subscription.current.subscription_id

  tags = var.tags
}

# read/write tf state
resource "azurerm_role_assignment" "core_cd_tfinf" {
  scope                = data.azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.core_cd_gh_federated_env.principal_id
}

# rg contributor (for example)
resource "azurerm_role_assignment" "core_cd_sub_contributor" {
  scope                = data.azurerm_resource_group.target.id
  role_definition_name = "Contributor"
  principal_id         = module.core_cd_gh_federated_env.principal_id
}
```


# allow to access the terraform state
resource "azurerm_role_assignment" "core_cd_tfinf" {
  scope                = data.azurerm_storage_account.tfinf.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.core_cd_gh_federated_env.principal_id
}

# subscription contributor
# TODO: maybe restrict to ict-<env>-shared-rg
resource "azurerm_role_assignment" "core_cd_sub_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = module.core_cd_gh_federated_env.principal_id
}


<!-- markdownlint-disable -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.116.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.29.0 |
| <a name="provider_github"></a> [github](#provider\_github) | 6.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_federated_identity_credential.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [github_actions_environment_secret.arm_client_id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret) | resource |
| [github_actions_environment_secret.arm_subscription_id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret) | resource |
| [github_actions_environment_secret.arm_tenant_id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret) | resource |
| [github_repository_environment.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_environment"></a> [github\_environment](#input\_github\_environment) | Name of the GitHub environment to provision | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | Name of the GitHub org in which operate | `string` | n/a | yes |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | Name of the GitHub repository in which operate | `string` | n/a | yes |
| <a name="input_identity_name"></a> [identity\_name](#input\_identity\_name) | Name of the Azure managed identity to provision | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Name of the Azure location in which to provision the man. identity | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Azure resource group in which to provision the man. identity | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription id | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags of Azure resources | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Azure tenant id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_environment"></a> [environment](#output\_environment) | GitHub environment |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | Principal id of the managed identity federated with GitHub environment |
<!-- END_TF_DOCS -->
