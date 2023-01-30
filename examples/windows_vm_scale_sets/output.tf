output "admin_ssh_key_public" {
  description = "The generated public key data in PEM format"
  value       = module.vmscaleset.admin_ssh_key_public
}

output "admin_ssh_key_private" {
  description = "The generated private key data in PEM format"
  value       = module.vmscaleset.admin_ssh_key_private
}

output "windows_vm_password" {
  description = "Password for the windows VM"
  value       = module.vmscaleset.windows_vm_password
}

output "linux_vm_password" {
  description = "Password for the Linux VM"
  value       = module.vmscaleset.linux_vm_password
}

output "load_balancer_public_ip" {
  description = "The Public IP address allocated for load balancer"
  value       = module.vmscaleset.load_balancer_public_ip
}

output "load_balancer_nat_pool_id" {
  description = "The resource ID of the Load Balancer NAT pool."
  value       = module.vmscaleset.load_balancer_nat_pool_id
}

output "load_balancer_health_probe_id" {
  description = "The resource ID of the Load Balancer Probe."
  value       = module.vmscaleset.load_balancer_health_probe_id
}

output "load_balancer_rules_id" {
  description = "The resource ID of the Load Balancer Rule"
  value       = module.vmscaleset.load_balancer_rules_id
}

output "network_security_group_id" {
  description = "The resource id of Network security group"
  value       = module.vmscaleset.network_security_group_id
}

output "linux_virtual_machine_scale_set_name" {
  description = "The name of the Linux Virtual Machine Scale Set."
  value       = module.vmscaleset.linux_virtual_machine_scale_set_name
}

output "linux_virtual_machine_scale_set_id" {
  description = "The resource ID of the Linux Virtual Machine Scale Set."
  value       = module.vmscaleset.linux_virtual_machine_scale_set_id
}

output "linux_virtual_machine_scale_set_unique_id" {
  description = "The unique ID of the Linux Virtual Machine Scale Set."
  value       = module.vmscaleset.linux_virtual_machine_scale_set_unique_id
}

output "windows_virtual_machine_scale_set_name" {
  description = "The name of the windows Virtual Machine Scale Set."
  value       = module.vmscaleset.windows_virtual_machine_scale_set_name
}

output "windows_virtual_machine_scale_set_id" {
  description = "The resource ID of the windows Virtual Machine Scale Set."
  value       = module.vmscaleset.windows_virtual_machine_scale_set_id
}

output "windows_virtual_machine_scale_set_unique_id" {
  description = "The unique ID of the windows Virtual Machine Scale Set."
  value       = module.vmscaleset.windows_virtual_machine_scale_set_unique_id
}

