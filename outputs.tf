# output "linux_vm_public_ip" {
#   value = "${module.vault-server.public_ip_address}"
# }

output "windows_client_public_ip" {
value = "${module.windows-client.public_ip_address}"
}

output "AD_vm_private_ip" {
  value = "${module.active-directory-domain.private_ip_address}"
}
