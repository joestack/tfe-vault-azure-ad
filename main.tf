variable "resource_group_name" {}
variable "environment_tag" {}
variable "location" {}
variable "admin_username" {}
variable "admin_password" {}
variable "prefix" {}








module "network" {
  source  = "app.terraform.io/JoeStack/network/azurerm"
  version = "2.0.0"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["${var.prefix}subnet1"]

  tags                = {
                          environment = "${var.environment_tag}"
                        }
}

module "ad-create" {
  source  = "app.terraform.io/JoeStack/ad-create/azurerm"
  version = "1.0.0"
  admin_password = "${var.admin_password}"
  admin_username = "${var.admin_username}"
  location = "${var.location}"
  prefix = "${var.prefix}"
#  #private_ip_address = "${cidrhost(module.network.subnet1, 10)}"
  private_ip_address = "10.0.1.10"
  resource_group_name = "${var.resource_group_name}"
  subnet_id = "${module.network.vnet_subnets[0]}"
  #subnet_id = "${module.network.azurerm_subnet.0.id}"
}

resource "azurerm_subnet" "subnet" {
  name  = "subnet1"
  address_prefix = "10.0.1.0/24"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "${var.prefix}vnet"
  network_security_group_id = "${azurerm_network_security_group.rdp.id}"
}

resource "azurerm_network_security_group" "rdp" {
  depends_on          = ["module.network"]
  name                = "${var.prefix}rdp-sg"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  security_rule {
    name                       = "rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}
output "sn1_id" {
  value = "${module.network.vnet_subnets[0]}"
}
output "advm_public_ip" {
  value = "${module.ad-create.ad_public_ip}"
}