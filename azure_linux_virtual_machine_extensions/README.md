# Azure Linux Virtual Machine Extensions

Post-deploy extensions and configuration for Azure Linux virtual machines.

## Architecture

![architecture](./docs/module-arch.drawio.png)

## Example usage

TODO

<!-- markdownlint-disable -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.116.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.33.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_data_collection_rule_association.dce_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_monitor_data_collection_rule_association.dcr_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_virtual_machine_extension.aad_ssh_login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.azure_monitor_agent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad_ssh_login"></a> [aad\_ssh\_login](#input\_aad\_ssh\_login) | Azure AD (Entra ID) authentication extension | <pre>object({<br/>    enabled           = bool<br/>    extension_version = optional(string, "1.0")<br/>  })</pre> | <pre>{<br/>  "enabled": true<br/>}</pre> | no |
| <a name="input_azure_monitor_agent"></a> [azure\_monitor\_agent](#input\_azure\_monitor\_agent) | Azure Monitor Agent extension | <pre>object({<br/>    enabled                     = bool<br/>    extension_version           = optional(string, "1.33")<br/>    data_collection_rule_id     = optional(string, null)<br/>    data_collection_endpoint_id = optional(string, null)<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | Key Vault extension for keeping certs in sync with Key Vault | <pre>object({<br/>    enabled                  = bool<br/>    vault_uri                = string<br/>    cert_name                = string<br/>    cert_store_location      = string<br/>    extension_version        = optional(string, "3.0")<br/>    polling_interval_seconds = optional(number, 3600)<br/>  })</pre> | <pre>{<br/>  "cert_name": "none",<br/>  "cert_store_location": "none",<br/>  "enabled": false,<br/>  "vault_uri": "none"<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags of azure resources | `map(string)` | `{}` | no |
| <a name="input_virtual_machine_id"></a> [virtual\_machine\_id](#input\_virtual\_machine\_id) | Resource ID of the virtual machine to extend | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
