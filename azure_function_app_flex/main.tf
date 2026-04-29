
# private storage account for the function
resource "azurerm_storage_account" "this" {
  name                     = replace("${var.name}st", "-", "")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = var.tags
}

# storage container for the function
resource "azurerm_storage_container" "this" {
  name                  = var.name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

locals {
  storage_services = ["blob", "queue", "table"]
}

# private endpoints for storage
resource "azurerm_private_endpoint" "storage" {
  for_each = toset([
    "blob",
    "queue",
    "table",
  ])

  name                = "${var.name}-st-${each.key}-pep"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-st-${each.key}"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = [each.key]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-${each.key}"
    private_dns_zone_ids = [lookup(var.private_dns_zone_ids, each.key)]
  }

  tags = var.tags
}

# function app flex
resource "azurerm_function_app_flex_consumption" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  runtime_name           = var.runtime_name
  runtime_version        = var.runtime_version
  instance_memory_in_mb  = var.instance_memory_in_mb
  maximum_instance_count = var.maximum_instance_count

  virtual_network_subnet_id                      = var.vnet_integration_subnet_id
  public_network_access_enabled                  = false
  https_only                                     = true
  webdeploy_publish_basic_authentication_enabled = false

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.this.primary_blob_endpoint}${azurerm_storage_container.this.name}"
  storage_authentication_type = "SystemAssignedIdentity"

  app_settings = merge(var.app_settings, {
    "AzureWebJobsStorage__accountName" = azurerm_storage_account.this.name
  })

  identity {
    type = "SystemAssigned"
  }

  site_config {
    vnet_route_all_enabled                 = true
    application_insights_connection_string = var.application_insights_connection_string
    minimum_tls_version                    = "1.2"
    health_check_path                      = var.health_check_path
    health_check_eviction_time_in_min      = var.health_check_eviction_time_in_min
  }

  dynamic "always_ready" {
    for_each = var.always_ready
    content {
      name           = always_ready.value.name
      instance_count = always_ready.value.instance_count
    }
  }

  tags = var.tags

  depends_on = [
    azurerm_private_endpoint.storage
  ]

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      site_config[0].worker_count
    ]
  }
}

locals {
  roles = [
    "Storage Blob Data Owner",
    "Storage Queue Data Contributor",
    "Storage Table Data Contributor"
  ]
}

# rbac for function -> storage
resource "azurerm_role_assignment" "func_rbac" {
  for_each = toset([
    "Storage Blob Data Owner",
    "Storage Queue Data Contributor",
    "Storage Table Data Contributor"
  ])

  scope                = azurerm_storage_account.this.id
  role_definition_name = each.value
  principal_id         = azurerm_function_app_flex_consumption.this.identity[0].principal_id
}

# private endpoint for function app (inbound traffic)
resource "azurerm_private_endpoint" "func" {
  name                = "${var.name}-pep"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-func"
    private_connection_resource_id = azurerm_function_app_flex_consumption.this.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-sites"
    private_dns_zone_ids = [var.private_dns_zone_ids["sites"]]
  }

  tags = var.tags
}
