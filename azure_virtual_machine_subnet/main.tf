# get the bastion subnet
data "azurerm_subnet" "bastion" {
  count = var.management_access.type == "Bastion" ? 1 : 0

  name                 = "AzureBastionSubnet" # this is fixed by azure for bastion subnet
  virtual_network_name = var.management_access.bastion_vnet_name
  resource_group_name  = var.management_access.bastion_resource_group_name
}

# subnet for the kmind frontend
resource "azurerm_subnet" "this" {
  name                 = var.name
  address_prefixes     = var.address_prefixes
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
}

# network security group
resource "azurerm_network_security_group" "this" {
  name                = "${var.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# associate nsg to subnet
resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

locals {
  # map (remote access type) -> (remote access source addresses)
  mgmt_access_src_address_prefixes = {
    "Bastion"  = var.management_access.type == "Bastion" ? data.azurerm_subnet.bastion[0].address_prefixes : []
    "Public"   = ["*"]
    "IpRanges" = var.management_access.ip_ranges
  }
}

# allow ssh from the management source if needed
resource "azurerm_network_security_rule" "inbound_allow_ssh" {
  count = var.management_access.ssh_enabled ? 1 : 0

  network_security_group_name = azurerm_network_security_group.this.name
  resource_group_name         = var.resource_group_name

  name                         = format("Inbound_Allow%sSSH", title(var.management_access.type))
  priority                     = 500
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "22"
  source_address_prefixes      = local.mgmt_access_src_address_prefixes[var.management_access.type]
  destination_address_prefixes = azurerm_subnet.this.address_prefixes
}

# allow rdp from the management source if needed
resource "azurerm_network_security_rule" "inbound_allow_rdp" {
  count = var.management_access.rdp_enabled ? 1 : 0

  network_security_group_name = azurerm_network_security_group.this.name
  resource_group_name         = var.resource_group_name

  name                         = format("Inbound_Allow%sRDP", title(var.management_access.type))
  priority                     = 501
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "3389"
  source_address_prefixes      = local.mgmt_access_src_address_prefixes[var.management_access.type]
  destination_address_prefixes = azurerm_subnet.this.address_prefixes
}

# allow traffic within the subnet
resource "azurerm_network_security_rule" "inbound_allow_subnet_self" {
  network_security_group_name = azurerm_network_security_group.this.name
  resource_group_name         = var.resource_group_name

  name                         = "Inbound_AllowSubnetSelf"
  priority                     = 550
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefixes      = azurerm_subnet.this.address_prefixes
  destination_address_prefixes = azurerm_subnet.this.address_prefixes
}

# allowed services are inbound traffic rules with named target service and source
resource "azurerm_network_security_rule" "inbound_allow_service" {
  for_each = { for svc in var.exposed_services : svc.name => svc }

  network_security_group_name = azurerm_network_security_group.this.name
  resource_group_name         = var.resource_group_name

  name                    = format("Inbound_Allow%sTo%s", replace(title(each.value.name), "/(\\s+|-)+/", ""), replace(title(each.value.source_name), "/(\\s|-)+/", ""))
  priority                = 600 + index(var.exposed_services, each.value)
  direction               = "Inbound"
  access                  = "Allow"
  protocol                = each.value.protocol
  source_port_range       = each.value.source_port_range
  destination_port_range  = each.value.port
  source_address_prefix   = each.value.source_address_prefix
  source_address_prefixes = each.value.source_address_prefixes
  # destination defaults to the whole subnet
  destination_address_prefixes = each.value.destination_address_prefixes != null ? each.value.destination_address_prefixes : azurerm_subnet.this.address_prefixes
}

# by default we block ALL traffic, included from within the VM!
resource "azurerm_network_security_rule" "inbound_deny_all" {
  network_security_group_name = azurerm_network_security_group.this.name
  resource_group_name         = var.resource_group_name

  name                         = "Inbound_Deny_All"
  priority                     = 1000
  direction                    = "Inbound"
  access                       = "Deny"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefixes = azurerm_subnet.this.address_prefixes
}
