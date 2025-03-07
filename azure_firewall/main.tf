# public ip of the firewall
resource "azurerm_public_ip" "firewall" {
  name                = "${var.base_name}-afw-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = var.tags
}

# public ip of the firewall management (forced-tunneling)
resource "azurerm_public_ip" "management" {
  name                = "${var.base_name}-afw-mgmt-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = var.tags
}

# subnet for the firewall
resource "azurerm_subnet" "firewall" {
  # the name must be this
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.subnet_address_prefixes
}

# subnet for the firewall management (forced-tunneling)
resource "azurerm_subnet" "management" {
  # the name must be this
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.mgmt_subnet_address_prefixes
}

# policy to attach, if not provided externally
resource "azurerm_firewall_policy" "this" {
  count = var.firewall_policy_id == null ? 1 : 0

  name                = "${var.base_name}-afwp"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku_tier

  tags = var.tags
}

# the firewall
resource "azurerm_firewall" "this" {
  name                = "${var.base_name}-afw"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = var.sku_tier
  firewall_policy_id  = var.firewall_policy_id == null ? azurerm_firewall_policy.this[0].id : var.firewall_policy_id

  # public ip of firewall
  ip_configuration {
    name                 = azurerm_public_ip.firewall.name
    public_ip_address_id = azurerm_public_ip.firewall.id
    subnet_id            = azurerm_subnet.firewall.id
  }

  # public ip of management (forced-tunneling)
  management_ip_configuration {
    name                 = azurerm_public_ip.management.name
    public_ip_address_id = azurerm_public_ip.management.id
    subnet_id            = azurerm_subnet.management.id
  }

  tags = var.tags
}

# send audit logs to security log analytics workspace
resource "azurerm_monitor_diagnostic_setting" "auditing_law" {
  count = var.auditing_log_analytics_workspace_id != null ? 1 : 0

  name                           = "Auditing_LogAnalytics"
  target_resource_id             = azurerm_firewall.this.id
  log_analytics_workspace_id     = var.auditing_log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "AZFWNatRule"
  }
  enabled_log {
    category = "AZFWNetworkRule"
  }
  enabled_log {
    category = "AZFWApplicationRule"
  }
  enabled_log {
    category = "AZFWThreatIntel"
  }
  enabled_log {
    category = "AZFWIdpsSignature"
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
  target_resource_id = azurerm_firewall.this.id
  storage_account_id = var.auditing_storage_account_id

  enabled_log {
    category = "AZFWNatRule"
  }
  enabled_log {
    category = "AZFWNetworkRule"
  }
  enabled_log {
    category = "AZFWApplicationRule"
  }
  enabled_log {
    category = "AZFWThreatIntel"
  }
  enabled_log {
    category = "AZFWIdpsSignature"
  }
  enabled_log {
    category = "AZFWDnsQuery"
  }
  enabled_log {
    category = "AZFWFatFlow"
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
  target_resource_id             = azurerm_firewall.this.id
  log_analytics_workspace_id     = var.monitoring_log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
