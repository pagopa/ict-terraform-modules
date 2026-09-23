// Workaround for azurerm provider bug (open at the time of writing):
// https://github.com/hashicorp/terraform-provider-azurerm/issues/33211
data "azapi_resource_action" "func_app_settings" {
  count = var.enable_azurewebjobsstorage_workaround ? 1 : 0

  type        = "Microsoft.Web/sites/config@2023-12-01"
  resource_id = "${azurerm_function_app_flex_consumption.this.id}/config/appsettings"
  action      = "list"
  method      = "POST"

  response_export_values = ["properties"]

  depends_on = [
    azurerm_function_app_flex_consumption.this
  ]
}

resource "azapi_update_resource" "func_app_settings_workaround" {
  count = var.enable_azurewebjobsstorage_workaround ? 1 : 0

  type      = "Microsoft.Web/sites/config@2023-12-01"
  name      = "appsettings"
  parent_id = azurerm_function_app_flex_consumption.this.id

  body = {
    properties = merge(
      data.azapi_resource_action.func_app_settings[0].output.properties,
      {
        AzureWebJobsStorage = ""
      }
    )
  }

  lifecycle {
    replace_triggered_by = [
      azurerm_function_app_flex_consumption.this
    ]
  }
}
