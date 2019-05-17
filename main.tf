terraform {
  required_version = ">= 0.11.1"
}

provider "azurerm" {}

resource "azurerm_resource_group" "demo" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
  tags = {
    environment = "${var.environment}"
    costcenter  = "${var.costcenter}"
  }
}

# Network

resource "azurerm_virtual_network" "demo" {
  name                = "demovn"
  address_space       = ["10.16.0.0/16"]
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  tags = {
    environment = "${var.environment}"
    costcenter  = "${var.costcenter}"
  }
}

resource "azurerm_subnet" "demo" {
  name                 = "demosub"
  resource_group_name  = "${azurerm_resource_group.demo.name}"
  virtual_network_name = "${azurerm_virtual_network.demo.name}"
  address_prefix       = "10.16.1.0/24"
}

resource "azurerm_public_ip" "demo" {
  name                 = "demo-pup-ip"
  location             = "${azurerm_resource_group.demo.location}"
  resource_group_name  = "${azurerm_resource_group.demo.name}"
  public_ip_address_allocation    = "Dynamic"
  tags = {
    environment = "${var.environment}"
    costcenter  = "${var.costcenter}"
  }
}

resource "azurerm_network_security_group" "demo" {
  name                = "demo-sg"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  
  security_rule = {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "${var.environment}"
    costcenter  = "${var.costcenter}"
  }
}

resource "azurerm_network_interface" "demo" {
  name                = "demo-nic"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  network_security_group_id = "${azurerm_network_security_group.demo.id}"

  ip_configuration = {
    name                          = "myNicConfiguration"
    subnet_id                     = "${azurerm_subnet.demo.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.demo.id}"
  }

  tags = {
    environment = "${var.environment}"
    costcenter  = "${var.costcenter}"
  }
}

resource "random_id" "demo" {
  keepers = {
      # Generate a new ID only when a new resource group is defined
      resource_group = "${azurerm_resource_group.demo.name}"
  }  
  byte_length = 8
}

resource "azurerm_storage_account" "demo" {
    name                = "diag${random_id.demo.hex}"
    resource_group_name = "${azurerm_resource_group.demo.name}"
    location            = "${azurerm_resource_group.demo.location}"
    account_replication_type = "LRS"
    account_tier = "Standard"
    tags = {
      environment = "${var.environment}"
      costcenter  = "${var.costcenter}"
    }
}
resource "azurerm_virtual_machine" "demo" {
  name                  = "demo-vault-vm"
  location              = "${azurerm_resource_group.demo.location}"
  resource_group_name   = "${azurerm_resource_group.demo.name}"
  network_interface_ids = ["${azurerm_network_interface.demo.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk = {
    name              = "demo-vault-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile = {
    computer_name  = "demo-vault-vm"
    admin_username = "azureuser"
  }

  os_profile_linux_config = {
    disable_password_authentication = true
    ssh_keys {
        path     = "/home/azureuser/.ssh/authorized_keys"
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