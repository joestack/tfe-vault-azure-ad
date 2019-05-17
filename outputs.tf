output "linux_vm_private_ips" {
    value = "${azurerm_virtual_machine.demo.network_interface_private_ip}"
  }