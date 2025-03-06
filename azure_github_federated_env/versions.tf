terraform {
  required_version = "~> 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
