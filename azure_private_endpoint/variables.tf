
# generic

variable "name" {
  type        = string
  description = "Name of the managed private endpoint"
}

variable "location" {
  type        = string
  description = "Location of the managed private endpoint"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "tags" {
  type        = map(string)
  description = "Tags of azure resources"
  default     = {}
}

# private endpoint

variable "subnet_id" {
  type        = string
  description = "ID of the subnet where to place the private endpoint"
}

variable "resource_id" {
  type        = string
  description = "ID of the resource exposed by the private endpoint"
}

variable "service" {
  type        = string
  description = "Name of the service exposed by the private endpoint"

  validation {
    condition = contains([
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
    ], var.service)
    error_message = "Service must be one of: AppService, StorageBlob, StorageDfs, StorageFile, StorageTable, StorageWeb, StorageAfs, StorageQueue, KeyVault, MySQL, SqlServer, AzureMonitor"
  }
}

variable "dns_zone_resource_group_name" {
  type        = string
  description = "Name of the resource group where the private DNS zone associated with the endpoint resides. If null, it will be searched in the same resource group where the private endpoint is about to be created"
  default     = null
}

