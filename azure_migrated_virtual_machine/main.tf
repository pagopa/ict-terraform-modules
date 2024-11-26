
# network interface of the migrated machine
resource "azurerm_network_interface" "this" {
  name                = "nic-${var.name}-00"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "nic-${var.name}-00-ipConfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# os managed disk
resource "azurerm_managed_disk" "os" {
  name                 = "${var.name}-OSdisk-00"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.storage_account_type
  create_option        = "Restore"
  disk_size_gb         = var.disk_size_gb
  hyper_v_generation   = var.hyper_v_generation
  os_type              = var.os_type

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # we don't know this, it usually is some obscure disk resource
      source_resource_id,
      # this tag is put by azure migrate and we want to leave it there
      tags["AzHydration-ManagedDisk-CreatedBy"],
    ]
  }
}

# virtual machine
resource "azurerm_virtual_machine" "this" {
  name                             = var.name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  network_interface_ids            = [azurerm_network_interface.this.id]
  primary_network_interface_id     = azurerm_network_interface.this.id
  vm_size                          = var.size
  delete_data_disks_on_termination = false
  delete_os_disk_on_termination    = false

  storage_os_disk {
    name            = azurerm_managed_disk.os.name
    managed_disk_id = azurerm_managed_disk.os.id
    create_option   = "Attach"
  }

  identity {
    type         = var.identity.type
    identity_ids = var.identity.identity_ids
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # the azurerm_virtual_machine is old and this will not match
      boot_diagnostics,
      # just ignore
      delete_data_disks_on_termination,
      delete_os_disk_on_termination,
    ]
  }
}
