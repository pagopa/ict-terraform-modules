# general

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

variable "index_suffix" {
  type        = string
  description = "Index suffix for the VM and related resource, for example set '01' for having a 'test' VM named 'test-vm-01'"
  default     = null
}

# networking

variable "subnet_id" {
  type        = string
  description = "Id of the subnet in which to deploy the VM. Not used when providing network_interface_ids"
  default     = null
}

variable "private_ip_address_allocation" {
  type        = string
  description = "Mode of allocation of private ip. Not used when providing network_interface_ids"
  default     = "Dynamic"
}

variable "private_ip_address" {
  type        = string
  description = "Private ip address if allocation mode is static. Not used when providing network_interface_ids"
  default     = null
}

variable "network_interface_ids" {
  type        = list(string)
  description = "Network interfaces to attach to the VM. If null, a default one with private IP will be provided"
  default     = null
}

# vm

variable "size" {
  type        = string
  description = "Size of the VM"
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

variable "os_disk_caching" {
  type        = string
  description = "OS disk caching, see docs of os_disk group in azurerm_linux_virtual_machine"
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  type        = string
  description = "OS disk storage account type, see docs of os_disk group in azurerm_linux_virtual_machine"
  default     = "Standard_LRS"
}

# TODO single image varaiable object valued with validation
variable "image_id" {
  type        = string
  description = "ID of the image to deploy. Mutually exclusive with all other image_ variables."
  default     = null
}

variable "image_publisher" {
  type        = string
  description = "Image publisher, see docs of source_image_reference group in azurerm_linux_virtual_machine"
  default     = null
}

variable "image_offer" {
  type        = string
  description = "Image offer, see docs of source_image_reference group in azurerm_linux_virtual_machine"
  default     = null
}

variable "image_sku" {
  type        = string
  description = "Image sku, see docs of source_image_reference group in azurerm_linux_virtual_machine"
  default     = null
}

variable "image_version" {
  type        = string
  description = "Image version, see docs of source_image_reference group in azurerm_linux_virtual_machine"
  default     = null
}

variable "boot_diagnostics_enable" {
  type        = string
  description = "Enable boot diagnostics. Recommended: set to true"
  default     = false
}

variable "boot_diagnostics_storage_account_uri" {
  type        = string
  description = "The Primary/Secondary Endpoint for the Azure Storage Account which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor. Leaving null means: use a Azure managed storage account (recommended)"
  default     = null
}

variable "custom_data" {
  type        = string
  description = "Base64 encoded cloud init file"
  default     = null
}

variable "encryption_at_host_enabled" {
  type        = bool
  description = "Enable encryption at host. By default it is activated as Azure will complain if you don't"
  default     = true
}

#
# patching
#
variable "automatic_patching" {
  type        = bool
  description = "Enable automatic patching (neesd Customer Managed Schedule in Azure Maintenance Configuation)"
  default     = false
}
