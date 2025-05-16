
# generic

variable "base_name" {
  type        = string
  description = "Base name of the managed resources"
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
  description = "Name of the virtual network in which deploy the bastion"
}

variable "subnet_address_prefixes" {
  type        = list(string)
  description = "CIDRs of the subnet that will be created for the firewall"
}

variable "mgmt_subnet_address_prefixes" {
  type        = list(string)
  description = "CIDRs of the subnet that will be created for the firewall management"
}

variable "public_ip_reverse_fqdn" {
  type        = string
  description = "FQDN associated to the firewall public ip for reverse DNS lookup"
  default     = null
}

variable "public_ip_domain_name_label" {
  type        = string
  description = "Public ip domain name label for reverse DNS lookup"
  default     = null
}

# firewall

variable "firewall_policy_id" {
  type        = string
  description = "Id of the firewall policy to attach, if null a new one will be provided"
  default     = null
}

variable "sku_tier" {
  type        = string
  description = "SKU tier of the firewall"
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
