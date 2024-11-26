variable "name" {
  type        = string
  description = "Name of the virtual machine"
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

variable "size" {
  type        = string
  description = "Size of the VM"
}

variable "subnet_id" {
  type        = string
  description = "Subnet in which the VM is deployed"
}

variable "os_type" {
  type        = string
  description = "Type of OS"
}

variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(set(string), null)
  })
  description = "Identity attached to the VM. Consider leaving the default SystemAssigned, handy in most cases"
  default = {
    type         = "SystemAssigned"
    identity_ids = null
  }
}

variable "storage_account_type" {
  type        = string
  description = "Storage account type of the OS disk"
  default     = "StandardSSD_LRS"
}

variable "disk_size_gb" {
  type        = string
  description = "Size in GB of the OS disk"
}

variable "hyper_v_generation" {
  type        = string
  description = "Hyper-V generation, V1 or V2"

  validation {
    condition     = contains(["V1", "V2"], var.hyper_v_generation)
    error_message = "Hyper-V generation can be either V1 or V2"
  }
}
