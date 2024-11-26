
variable "tags" {
  type        = map(string)
  description = "Tags of azure resources"
  default     = {}
}

variable "virtual_machine_id" {
  type        = string
  description = "Resource ID of the virtual machine to extend"
}

variable "aad_ssh_login" {
  type = object({
    enabled           = bool
    extension_version = optional(string, "1.0")
  })
  description = "Azure AD (Entra ID) authentication extension"
  default = {
    enabled = true
  }
}

variable "azure_monitor_agent" {
  type = object({
    enabled                     = bool
    extension_version           = optional(string, "1.33")
    data_collection_rule_id     = optional(string, null)
    data_collection_endpoint_id = optional(string, null)
  })
  description = "Azure Monitor Agent extension"
  default = {
    enabled = false
  }

  validation {
    condition     = !var.azure_monitor_agent.enabled || var.azure_monitor_agent.data_collection_rule_id != null
    error_message = "data_collection_rule_id is required when azure monitor agent is enabled"
  }

  validation {
    condition     = !var.azure_monitor_agent.enabled || var.azure_monitor_agent.data_collection_endpoint_id != null
    error_message = "data_collection_endpoint_id is required when azure monitor agent is enabled"
  }
}
