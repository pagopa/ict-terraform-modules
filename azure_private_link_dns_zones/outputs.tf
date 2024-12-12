
output "private_dns_zones" {
  value = {
    for dns in azurerm_private_dns_zone.this : dns.name => {
      id                  = dns.id
      name                = dns.name
      resource_group_name = dns.resource_group_name
    }
  }
  description = "Private DNS zones managed"
}
