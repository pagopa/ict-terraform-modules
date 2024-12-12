
locals {
  # https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns
  dns_zones = {
    # the keys are the possible values of items in var.enabled_zones
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
}

resource "azurerm_private_dns_zone" "this" {
  for_each = toset(flatten([for s in var.services : local.dns_zones[s]]))

  name                = each.key
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
