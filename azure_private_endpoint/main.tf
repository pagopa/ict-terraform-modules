
locals {
  # https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns
  dns_zones = {
    # the keys are the possible values of var.service
    AppService   = ["privatelink.azurewebsites.net"]
    StorageBlob  = ["privatelink.blob.core.windows.net"]
    StorageDfs   = ["privatelink.dfs.core.windows.net"]
    StorageFile  = ["privatelink.file.core.windows.net"]
    StorageQueue = ["privatelink.queue.core.windows.net"]
    StorageTable = ["privatelink.table.core.windows.net"]
    StorageWeb   = ["privatelink.web.core.windows.net"]
    StorageAfs   = ["privatelink.afs.azure.net"]
    KeyVault     = ["privatelink.vaultcore.azure.net"]
    MySQL        = ["privatelink.mysql.database.azure.com"]
    SqlServer    = ["privatelink.database.windows.net"]
    AzureMonitor = [
      "privatelink.monitor.azure.com",
      "privatelink.oms.opinsights.azure.com",
      "privatelink.ods.opinsights.azure.com",
      "privatelink.agentsvc.azure-automation.net",
      "privatelink.blob.core.windows.net",
    ]
  }
  service_names = {
    # the keys are the possible values of var.service
    AppService   = ["sites"]
    StorageBlob  = ["blob"]
    StorageDfs   = ["dfs"]
    StorageFile  = ["file"]
    StorageTable = ["table"]
    StorageWeb   = ["web"]
    StorageAfs   = ["afs"]
    StorageQueue = ["queue"]
    KeyVault     = ["vault"]
    MySQL        = ["mysqlServer"]
    SqlServer    = ["sqlServer"]
    AzureMonitor = ["azuremonitor"]
  }
}

data "azurerm_private_dns_zone" "private_endpoint" {
  for_each = toset(local.dns_zones[var.service])

  name                = each.key
  resource_group_name = var.dns_zone_resource_group_name != null ? var.dns_zone_resource_group_name : var.resource_group_name
}

resource "azurerm_private_endpoint" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = var.name
    private_connection_resource_id = var.resource_id
    is_manual_connection           = false
    subresource_names              = local.service_names[var.service]
  }

  private_dns_zone_group {
    name = "private-dns-zone-group"
    private_dns_zone_ids = [
      for dns in local.dns_zones[var.service] :
      data.azurerm_private_dns_zone.private_endpoint[dns].id
    ]
  }

  tags = var.tags
}
