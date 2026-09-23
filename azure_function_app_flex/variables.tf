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

variable "vnet_integration_subnet_id" {
  type        = string
  description = "ID of delegated subnet delegata for function outbound traffic"
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "ID of subnet where private endpoints (func and storage) will be created"
  default     = null

  validation {
    condition = var.private_endpoint_subnet_id != null || alltrue([
      for zone_id in values(var.private_dns_zone_ids) : (zone_id == null ? "" : trimspace(zone_id)) == ""
    ])
    error_message = "private_endpoint_subnet_id is required when at least one private endpoint DNS zone ID is provided."
  }
}

variable "private_dns_zone_ids" {
  type = object({
    blob  = optional(string, null)
    queue = optional(string, null)
    table = optional(string, null)
    sites = optional(string, null)
  })
  description = "IDs of private DNS zones for private endpoints. Set each value to null (or empty) to disable the corresponding private endpoint."
  default     = {}
}


# app service

variable "service_plan_id" {
  type        = string
  description = "ID of App Service Plan (SKU FC1)"
}

variable "runtime_name" {
  type        = string
  description = "Runtime of the func"
}

variable "runtime_version" {
  type        = string
  description = "Runtime version of the func"
}

variable "instance_memory_in_mb" {
  type        = number
  description = "Instance memory in MB"
  default     = 512
}

variable "always_ready" {
  type = list(object({
    name           = string
    instance_count = number
  }))
  description = "List of Always Ready configurations. The 'name' field can be the trigger type (e.g., 'http') or the specific function name."
  default     = []
}

variable "app_settings" {
  type        = map(string)
  description = "Application configuration environment variables"
  default     = {}
}

variable "application_insights_connection_string" {
  type    = string
  default = null
}

variable "maximum_instance_count" {
  type        = number
  description = "Max instacne count (autoscaling)"
  default     = 1
}

variable "health_check_path" {
  description = "The path on which the Health Check service will ping (e.g., /api/health). Must start with a forward slash."
  type        = string
  default     = null
}

variable "health_check_eviction_time_in_min" {
  description = "The amount of time in minutes (between 2 and 10) that a node can be unhealthy before being removed from the load balancer."
  type        = number
  default     = 2
}

variable "enable_azurewebjobsstorage_workaround" {
  type        = bool
  description = "Enable workaround for azurerm_function_app_flex_consumption issue #33211 by forcing AzureWebJobsStorage to an empty value."
  default     = true
}
