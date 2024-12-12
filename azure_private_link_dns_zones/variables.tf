
# generic

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "tags" {
  type        = map(string)
  description = "Tags of azure resources"
  default     = {}
}

# specific

variable "services" {
  type        = list(string)
  description = "Azure services for which to create a private DNS zone for private endpoints"

  validation {
    condition = alltrue([
      for s in var.services : contains([
        "AppService",
        "StorageBlob",
        "StorageDfs",
        "StorageFile",
        "StorageTable",
        "StorageWeb",
        "StorageAfs",
        "StorageQueue",
        "KeyVault",
        "MySQL",
        "SqlServer",
        "AzureMonitor",
      ], s)
    ])
    error_message = "Services must be in the set: AppService, StorageBlob, StorageDfs, StorageFile, StorageTable, StorageWeb, StorageAfs, StorageQueue, KeyVault, MySQL, SqlServer, AzureMonitor"
  }
}

