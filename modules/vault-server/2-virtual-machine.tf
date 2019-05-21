locals {
  virtual_machine_name = "${var.prefix}-vault"
}

resource "azurerm_virtual_machine" "vault" {
  name                          = "${local.virtual_machine_name}"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  network_interface_ids         = ["${azurerm_network_interface.primary.id}"]
  vm_size                       = "Standard_F2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${local.virtual_machine_name}-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.virtual_machine_name}"
    admin_username = "${var.admin_username}"
  }

  os_profile_linux_config = {
    disable_password_authentication = true
    ssh_keys {
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
        key_data = "${var.ssh_keys}"
    }
  }

  boot_diagnostics = {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.demo.primary_blob_endpoint}"
  }

  tags = {
    environment = "${var.environment}"
    costcenter  = "${var.costcenter}"
  }
}
