variable "scaleset_name" {
  description = "Scaleset name"
}

variable "dns_name" {
  description = "Dns name for load balancer PIP"
}

resource "azurerm_resource_group" "mytfrg" {
  name     = "scaleset-rg"
  location = "WestEurope"
}

resource "azurerm_virtual_network" "mytfvnet" {
  name                = "${var.scaleset_name}-vnet"
  resource_group_name = "${azurerm_resource_group.mytfrg.name}"
  location            = "WestEurope"
  address_space       = ["172.17.0.0/16"]
}

resource "azurerm_subnet" "mytfsubnet" {
  name                 = "subnet1"
  resource_group_name  = "${azurerm_virtual_network.mytfvnet.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.mytfvnet.name}"
  address_prefix       = "172.17.0.0/24"
}

module "linux-vm" {
  source              = "../../"
  resource_group_name = "${azurerm_subnet.mytfsubnet.resource_group_name}-lin"
  name                = "${var.scaleset_name}"
  location            = "WestEurope"
  adminPassword       = "Welcome@123456"
  os_type             = "linux"
  dns_name            = "${var.dns_name}lin"
  vnet_subnet_id      = "${azurerm_subnet.mytfsubnet.id}"
}

module "windows-vm" {
  source              = "../../"
  resource_group_name = "${azurerm_subnet.mytfsubnet.resource_group_name}-win"
  name                = "${var.scaleset_name}"
  location            = "WestEurope"
  adminPassword       = "Welcome@123456"
  os_type             = "windows"
  dns_name            = "${var.dns_name}win"
  vnet_subnet_id      = "${azurerm_subnet.mytfsubnet.id}"
}

output "lb_publicip_id" {
  description = "Public IP of the load balancer"
  value       = "${module.linux-vm.lb_publicip}"
}
