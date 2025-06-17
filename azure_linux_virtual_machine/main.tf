locals {
  index_suffix = var.index_suffix == null ? "" : "-${var.index_suffix}"
  # the try is needed, the terraform operators do not short-circuit (https://developer.hashicorp.com/terraform/language/expressions/operators#logical-operators)
  do_create_nic = var.network_interface_ids == null || try(length(var.network_interface_ids) == 0, true)
}

# create an SSH key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# public key to azure
resource "azurerm_ssh_public_key" "public_key" {
  name                = "${var.base_name}-vm${local.index_suffix}-admin-access-key"
  resource_group_name = var.resource_group_name
  location            = var.location
  public_key          = tls_private_key.ssh.public_key_openssh
}

# network interface with private ip
resource "azurerm_network_interface" "internal" {
  count = local.do_create_nic ? 1 : 0

  name                = "${var.base_name}-nic${local.index_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address            = var.private_ip_address
  }

  tags = var.tags
}

# virtual machine
resource "azurerm_linux_virtual_machine" "this" {
  name                  = "${var.base_name}-vm${local.index_suffix}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = local.do_create_nic ? [azurerm_network_interface.internal[0].id] : var.network_interface_ids
  size                  = var.size

  bypass_platform_safety_checks_on_user_schedule_enabled = var.automatic_patching
  patch_assessment_mode                                  = var.automatic_patching ? "AutomaticByPlatform" : "ImageDefault"
  patch_mode                                             = var.automatic_patching ? "AutomaticByPlatform" : "ImageDefault"

  custom_data = var.custom_data

  os_disk {
    name                 = "${var.base_name}-os-disk${local.index_suffix}"
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_id = var.image_id

  dynamic "source_image_reference" {
    for_each = var.image_id == null ? ["dummy"] : []
    content {
      publisher = var.image_publisher
      offer     = var.image_offer
      sku       = var.image_sku
      version   = var.image_version
    }
  }

  computer_name  = "${var.base_name}${local.index_suffix}"
  admin_username = "${var.base_name}${local.index_suffix}"
  # opinionated! you just can't
  disable_password_authentication = true

  admin_ssh_key {
    username   = "${var.base_name}${local.index_suffix}"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics_enable ? ["dummy"] : []
    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  identity {
    type         = var.identity.type
    identity_ids = var.identity.identity_ids
  }

  tags = var.tags
}
