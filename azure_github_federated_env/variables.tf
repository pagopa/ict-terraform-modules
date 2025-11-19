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

variable "deployment_reviewer_team_ids" {
  type        = list(string)
  description = "IDs (graphql) of github teams entitled to review deployments in this environment. Without this and/or reviewer_user_ids no review will be asked."
  default     = []
}

variable "deployment_reviewer_user_ids" {
  type        = list(string)
  description = "IDs (graphql) of github users entitled to review deployments in this environment. Without this and/or reviewer_user_ids no review will be asked."
  default     = []
}
