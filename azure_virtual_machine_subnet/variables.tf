
variable "name" {
  type        = string
  description = "Name of the subnet"
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
  description = "Tag of azure resources"
  default     = {}
}

variable "address_prefixes" {
  type = list(string)
}

variable "virtual_network_name" {
  type = string
}

variable "management_access" {
  type = object({
    type                        = string
    ssh_enabled                 = optional(bool, false)
    rdp_enabled                 = optional(bool, false)
    bastion_vnet_name           = optional(string, null)
    bastion_resource_group_name = optional(string, null)
    ip_ranges                   = optional(list(string), [])
  })
  description = "Remote access for management of the VMs in the subnet"

  validation {
    condition     = contains(["Bastion", "Public", "IpRanges"], var.management_access.type)
    error_message = "type should be one of: Bastion, Public, IpRanges"
  }

  validation {
    condition     = var.management_access.type != "Bastion" || var.management_access.bastion_vnet_name != null
    error_message = "bastion_vnet_name is required for type = Bastion"
  }

  validation {
    condition     = var.management_access.type != "Bastion" || var.management_access.bastion_resource_group_name != null
    error_message = "bastion_resource_group_name is required for type = Bastion"
  }

  validation {
    condition     = var.management_access.type != "IpRanges" || var.management_access.ip_ranges != null
    error_message = "ip_ranges is required for type = IpRanges"
  }

  validation {
    condition     = var.management_access.ssh_enabled || var.management_access.rdp_enabled
    error_message = "One of ssh_enabled or rdp_enabled must be true"
  }
}

variable "exposed_services" {
  type = list(object({
    name                         = string
    protocol                     = string
    source_port_range            = optional(string, "*")
    port                         = string
    source_name                  = string
    source_address_prefix        = optional(string, null)
    source_address_prefixes      = optional(list(string), null)
    destination_address_prefixes = optional(list(string), null)
  }))
  description = "Services that are exposed by the subnet and allowed in vnet"
  default     = []
}
