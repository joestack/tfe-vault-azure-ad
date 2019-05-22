output "private_ip_address" {
  value = "${azurerm_network_interface.primary.private_ip_address}"
}
