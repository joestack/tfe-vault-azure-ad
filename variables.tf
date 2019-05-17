variable "environment" {
  description = "Environment For Deployment"
  default = "demo"
}

variable "costcenter" {
  description = "Cost Center For This Deployment"
  default = "demo"
}

variable "location" {
  description = "Azure location in which to create resources"
  default = "East US"
}

variable "resource_group_name" {
  description = "Name for the resourcegroup"
  default = "vault-ad-demo"
}

variable "ssh_keys" {
  description = "List of SSh keys for the linux servers"
}
