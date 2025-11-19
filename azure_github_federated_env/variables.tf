variable "resource_group_name" {
  type        = string
  description = "Name of the Azure resource group in which to provision the man. identity"
}

variable "location" {
  type        = string
  description = "Name of the Azure location in which to provision the man. identity"
}

variable "tags" {
  type        = map(string)
  description = "Tags of Azure resources"
  default     = {}
}

variable "identity_name" {
  type        = string
  description = "Name of the Azure managed identity to provision"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant id"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription id"
}

variable "github_environment" {
  type        = string
  description = "Name of the GitHub environment to provision"
}

variable "github_repository" {
  type        = string
  description = "Name of the GitHub repository in which operate"
}

variable "github_org" {
  type        = string
  description = "Name of the GitHub org in which operate"
}

variable "deployments" {
  type = object({
    review_required    = bool
    reviewer_teams_ids = optional(list(string), [])
    reviewer_users_ids = optional(list(string), [])
  })
  default = {
    review_required    = false
    reviewer_teams_ids = []
    reviewer_users_ids = []
  }
  description = "Configure deployments for the current environment"
}
