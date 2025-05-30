#
# Entra ID auth
#

resource "azurerm_virtual_machine_extension" "aad_ssh_login" {
  count = var.aad_ssh_login.enabled ? 1 : 0

  name                       = "AADSSHLogin"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = var.aad_ssh_login.extension_version
  auto_upgrade_minor_version = true

  tags = var.tags
}

#
# Azure Monitor Agent
#

resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  count = var.azure_monitor_agent.enabled ? 1 : 0

  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = var.azure_monitor_agent.extension_version
  auto_upgrade_minor_version = true

  tags = var.tags
}

# associate the vm to a data collection rule
resource "azurerm_monitor_data_collection_rule_association" "dcr_association" {
  count = var.azure_monitor_agent.enabled ? 1 : 0

  name                    = "configurationAccessRule"
  target_resource_id      = var.virtual_machine_id
  data_collection_rule_id = var.azure_monitor_agent.data_collection_rule_id
}

# associate the vm to a data collection endpoint
resource "azurerm_monitor_data_collection_rule_association" "dce_association" {
  count = var.azure_monitor_agent.enabled && var.azure_monitor_agent.data_collection_endpoint_id != null ? 1 : 0

  # it seems that the name must be precisely this one
  name                        = "configurationAccessEndpoint"
  target_resource_id          = var.virtual_machine_id
  data_collection_endpoint_id = var.azure_monitor_agent.data_collection_endpoint_id
}


#
# Key Vault
#

# https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/key-vault-linux
resource "azurerm_virtual_machine_extension" "key_vault" {
  count = var.key_vault.enabled ? 1 : 0

  name                       = "KVVMExtensionForLinux"
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = "Microsoft.Azure.KeyVault"
  type                       = "KeyVaultForLinux"
  type_handler_version       = var.key_vault.extension_version
  auto_upgrade_minor_version = true

  settings = <<EOT
{
  "secretsManagementSettings": {
    "pollingIntervalInS": "${var.key_vault.polling_interval_seconds}",
    "linkOnRenewal": false,
    "requireInitialSync": true,
    "aclEnabled": false,
    "observedCertificates": [
      {
        "url": "${var.key_vault.vault_uri}/secrets/${var.key_vault.cert_name}",
        "certificateStoreLocation": "${var.key_vault.cert_store_location}",
        "customSymbolicLinkName": "${var.key_vault.cert_name}"
      }
    ]
  }
}
EOT

  tags = var.tags
}
