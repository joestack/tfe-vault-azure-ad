variable "resource_group_name" {}
variable "environment_tag" {}
variable "location" {}



module "network" {
  source  = "app.terraform.io/JoeStack/network/azurerm"
  version = "2.0.0"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]

  tags                = {
                          environment = "${var.environment_tag}"
                        }
}