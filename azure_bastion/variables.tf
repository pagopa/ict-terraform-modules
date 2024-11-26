# generic

variable "name" {
  type        = string
  description = "Name of the bastion"
}

variable "location" {
  type        = string
  description = "Location"
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

# networking

variable "virtual_network_name" {
  type        = string
  description = "Name of the VNET in which to deploy the bastion"
}

variable "subnet_address_prefixes" {
  type        = list(string)
  description = "CIDRs of the bastion subnet that will be created. Must be at least of size /26"
}

variable "public_ip_id" {
  type        = string
  description = "ID of the public ip to attach to the bastion; if null, a new one will be created"
  default     = null
}

# bastion

variable "sku" {
  type        = string
  description = "Sku of the bastion"
}

variable "scale_units" {
  type        = number
  description = "Scale units of the bastion, leave default for most use cases"
  default     = 2

  validation {
    condition     = var.scale_units >= 2 && var.scale_units <= 50
    error_message = "Scale units must be 2 <= scale units <= 50"
  }
}

# observability

variable "auditing_log_analytics_workspace_id" {
  type        = string
  description = "ID of the log analytics workspace used for auditing purposes"
  default     = null
}

variable "auditing_storage_account_id" {
  type        = string
  description = "ID of the storage account used for auditing purposes"
  default     = null
}

variable "monitoring_log_analytics_workspace_id" {
  type        = string
  description = "ID of the log analytics workspace used for monitoring purposes"
  default     = null
}
