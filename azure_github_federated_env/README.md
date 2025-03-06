# Azure GitHub federated environment

Provision a GitHub environment for deploying AzureRM based workloads (for example, IaC with Terraform) with federated identity.

It creates:

* Azure managed identity
* GitHub environment
* Azure federated credentials of the identity allowing login from the GitHub environment 
* GitHub environment secrets for logging in with the federated credentials in that environment:
  * `ARM_TENANT_ID`. AzureRM tenant id
  * `ARM_SUBSCRIPTION_ID`. AzureRM subscription id
  * `ARM_CLIENT_ID`. AzureRM client id of the managed identity to use
