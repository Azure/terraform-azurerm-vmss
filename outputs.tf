output "resource_group_id" {
  description = "Resource group of the scaleset"
  value       = "${azurerm_resource_group.vmss-rg.id}"
}

output "scaleset_id" {
  description = "Scaleset"
  value       = "${concat("${azurerm_virtual_machine_scale_set.standard-linux-vmss.*.id}","${azurerm_virtual_machine_scale_set.standard-windows-vmss.*.id}")}"
}

output "loadbalancer_id" {
  description = "Load balancer"
  value       = "${azurerm_lb.vmss-lb.id}"
}

output "lb_publicip_id" {
  description = "Public IP id of the load balancer"
  value       = "${azurerm_public_ip.publicip.id}"
}

output "lb_publicip" {
  description = "Public IP of the load balancer"
  value       = "${azurerm_public_ip.publicip.ip_address}"
}
