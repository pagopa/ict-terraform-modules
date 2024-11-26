
# subnet in which to deploy the bastion
# https://learn.microsoft.com/en-us/azure/bastion/configuration-settings#subnet
resource "azurerm_subnet" "bastion" {
  # exactly this name is mandatory
  name                 = "AzureBastionSubnet"
  address_prefixes     = var.subnet_address_prefixes
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

# public ip of the bastion
resource "azurerm_public_ip" "bastion" {
  count = var.public_ip_id == null ? 1 : 0

  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

locals {
  public_ip_id = var.public_ip_id != null ? var.public_ip_id : azurerm_public_ip.bastion[0].id
}

resource "azurerm_bastion_host" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  scale_units         = var.scale_units
  # yes please
  copy_paste_enabled = true
  # we always want these, but they are not available in basic.
  # this is opininated! just avoiding you errors like: "basic does not support shareable link bla"
  shareable_link_enabled = var.sku != "Basic"
  file_copy_enabled      = var.sku != "Basic"
  # when setting this to true, mind this: https://codyburkard.com/blog/bastionabuse/
  # the tunneling might lead to port scan and reaching other ports
  # than the ssh one on the target VM. therefore, use a NSG that
  # blocks all except of port 22 from the bastion subnet!
  tunneling_enabled = var.sku != "Basic"

  ip_configuration {
    name                 = "config-01"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = local.public_ip_id
  }

  tags = var.tags
}

# send audit logs to security log analytics workspace
resource "azurerm_monitor_diagnostic_setting" "auditing_law" {
  count = var.auditing_log_analytics_workspace_id != null ? 1 : 0

  name                           = "Auditing_LogAnalytics"
  target_resource_id             = azurerm_bastion_host.this.id
  log_analytics_workspace_id     = var.auditing_log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "BastionAuditLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

# send audit logs to security storage account
resource "azurerm_monitor_diagnostic_setting" "auditing_storage" {
  count = var.auditing_storage_account_id != null ? 1 : 0

  name               = "Auditing_Storage"
  target_resource_id = azurerm_bastion_host.this.id
  storage_account_id = var.auditing_storage_account_id

  enabled_log {
    category = "BastionAuditLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

# send metrics to other log analytics workspace
resource "azurerm_monitor_diagnostic_setting" "monitoring_law" {
  count = var.monitoring_log_analytics_workspace_id != null ? 1 : 0

  name                           = "Monitoring_LogAnalytics"
  target_resource_id             = azurerm_bastion_host.this.id
  log_analytics_workspace_id     = var.monitoring_log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
