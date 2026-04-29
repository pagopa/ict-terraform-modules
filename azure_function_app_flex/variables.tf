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
}

variable "private_dns_zone_ids" {
  type = object({
    blob  = string
    queue = string
    table = string
    sites = string
  })
  description = "IDs of private DNS zones for private endpoints"
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
