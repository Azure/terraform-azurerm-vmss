provider "azurerm" {
  version = ">=1.16.0"
}

resource "azurerm_resource_group" vmss-rg {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_public_ip" "publicip" {
  name                = "${var.name}pip"
  location            = "${azurerm_resource_group.vmss-rg.location}"
  resource_group_name = "${azurerm_resource_group.vmss-rg.name}"
  sku                 = "${var.lb_sku}"
  allocation_method   = "${var.publicip_allocation}"
  domain_name_label   = "${var.dns_name}"
}

resource "azurerm_lb" "vmss-lb" {
  name                = "${var.name}lb"
  location            = "${azurerm_resource_group.vmss-rg.location}"
  resource_group_name = "${azurerm_resource_group.vmss-rg.name}"
  sku                 = "${var.lb_sku}"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.publicip.id}"
  }

  tags = "${var.tags}"
}

resource "azurerm_lb_backend_address_pool" "lb-backend-pool" {
  resource_group_name = "${azurerm_resource_group.vmss-rg.name}"
  loadbalancer_id     = "${azurerm_lb.vmss-lb.id}"
  name                = "Backendpool"
}

resource "azurerm_lb_nat_pool" "lb-nat-pool" {
  resource_group_name            = "${azurerm_resource_group.vmss-rg.name}"
  name                           = "natpool"
  loadbalancer_id                = "${azurerm_lb.vmss-lb.id}"
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = "${("${var.os_type}" == "linux") ? "22":"3389"}"
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
}

resource "azurerm_lb_probe" "lb-probe" {
  resource_group_name = "${azurerm_resource_group.vmss-rg.name}"
  loadbalancer_id     = "${azurerm_lb.vmss-lb.id}"
  name                = "tcpProbe"
  protocol            = "TCP"
  port                = "80"
}

resource "azurerm_lb_rule" "lb-rule" {
  resource_group_name            = "${azurerm_resource_group.vmss-rg.name}"
  loadbalancer_id                = "${azurerm_lb.vmss-lb.id}"
  name                           = "Lbrule1"
  protocol                       = "Tcp"
  frontend_port                  = "80"
  backend_port                   = "80"
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.lb-backend-pool.id}"
  probe_id                       = "${azurerm_lb_probe.lb-probe.id}"
}

resource "azurerm_network_security_group" "remote-acccess-nsg" {
  name                = "RemoteAccessNSG"
  location            = "${azurerm_resource_group.vmss-rg.location}"
  resource_group_name = "${azurerm_resource_group.vmss-rg.name}"
}

resource "azurerm_network_security_rule" "remote-access-rule" {
  name                        = "Remoteaccess"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "${("${var.os_type}" == "linux") ? "22":"3389"}"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.vmss-rg.name}"
  network_security_group_name = "${azurerm_network_security_group.remote-acccess-nsg.name}"
}

resource "azurerm_virtual_machine_scale_set" "standard-linux-vmss" {
  count                  = "${ ("${var.os_type}" == "linux") ? "1":"0"}"
  name                   = "${var.name}"
  location               = "${azurerm_resource_group.vmss-rg.location}"
  resource_group_name    = "${azurerm_resource_group.vmss-rg.name}"
  single_placement_group = "${var.singleplacementgroup}"
  zones                  = "${var.zones}"

  //Automatic OS upgrade only works with standard images
  automatic_os_upgrade = "${ ("${var.custom_image_id}" != "")? "false":"true"}"
  upgrade_policy_mode  = "Rolling"
  health_probe_id      = "${azurerm_lb_probe.lb-probe.id}"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches              = "PT0S"
  }

  network_profile {
    name                      = "${var.name}nic"
    primary                   = "true"
    accelerated_networking    = "${var.accelerated_network}"
    ip_forwarding             = "${var.ip_forwarding}"
    network_security_group_id = "${azurerm_network_security_group.remote-acccess-nsg.id}"

    ip_configuration {
      name                                   = "${var.name}ipconfig"
      primary                                = "true"
      subnet_id                              = "${var.vnet_subnet_id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.lb-backend-pool.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.lb-nat-pool.*.id, count.index)}"]
    }
  }

  os_profile {
    computer_name_prefix = "${var.name}"
    admin_username       = "${var.adminUsername}"
    admin_password       = "${var.adminPassword}"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    //ssh_keys {
    //path     = "/home/azureuser/.ssh/authorized_keys"
    //key_data = "${file("${var.sshkeys}")}"
    //}
  }

  sku {
    name     = "${var.vm_size}"
    capacity = "${var.numberofVMs}"
  }

  storage_profile_image_reference {
    id        = "${var.custom_image_id}"
    publisher = "${var.custom_image_id != "" ? "" : var.vm_os_publisher == "" ? "Canonical" : "${var.vm_os_publisher}"}"
    offer     = "${var.custom_image_id != "" ? "" : var.vm_os_offer == "" ? "UbuntuServer" : "${var.vm_os_offer}"}"
    sku       = "${var.custom_image_id != "" ? "" : var.vm_os_sku == "" ? "18.04-LTS" : "${var.vm_os_sku}"}"
    version   = "${var.custom_image_id != "" ? "" : var.vm_os_version == "" ? "latest" : "${var.vm_os_version}"}"
  }

  storage_profile_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 32
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine_scale_set" "standard-windows-vmss" {
  count                  = "${ ("${var.os_type}" == "windows") ? "1":"0"}"
  name                   = "${var.name}"
  location               = "${azurerm_resource_group.vmss-rg.location}"
  resource_group_name    = "${azurerm_resource_group.vmss-rg.name}"
  single_placement_group = "${var.singleplacementgroup}"
  zones                  = "${var.zones}"

  //Automatic OS upgrade only works with standard images
  automatic_os_upgrade = "${ ("${var.custom_image_id}" != "")? "false":"true"}"
  upgrade_policy_mode  = "Rolling"
  health_probe_id      = "${azurerm_lb_probe.lb-probe.id}"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches              = "PT0S"
  }

  network_profile {
    name                      = "${var.name}nic"
    primary                   = "true"
    accelerated_networking    = "${var.accelerated_network}"
    ip_forwarding             = "${var.ip_forwarding}"
    network_security_group_id = "${azurerm_network_security_group.remote-acccess-nsg.id}"

    ip_configuration {
      name                                   = "${var.name}ipconfig"
      primary                                = "true"
      subnet_id                              = "${var.vnet_subnet_id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.lb-backend-pool.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.lb-nat-pool.*.id, count.index)}"]
    }
  }

  os_profile {
    computer_name_prefix = "${var.name}"
    admin_username       = "${var.adminUsername}"
    admin_password       = "${var.adminPassword}"
  }

  os_profile_windows_config {
    provision_vm_agent        = "${var.windows_vm_agent}"
    enable_automatic_upgrades = "${var.windows_auto_upgrade}"
  }

  sku {
    name     = "${var.vm_size}"
    capacity = "${var.numberofVMs}"
  }

  storage_profile_image_reference {
    id        = "${var.custom_image_id}"
    publisher = "${var.custom_image_id != "" ? "" : var.vm_os_publisher == "" ? "MicrosoftWindowsServer" : "${var.vm_os_publisher}"}"
    offer     = "${var.custom_image_id != "" ? "" : var.vm_os_offer == "" ? "WindowsServer" : "${var.vm_os_offer}"}"
    sku       = "${var.custom_image_id != "" ? "" : var.vm_os_sku == "" ? "2016-Datacenter" : "${var.vm_os_sku}"}"
    version   = "${var.custom_image_id != "" ? "" : var.vm_os_version == "" ? "latest" : "${var.vm_os_version}"}"
  }

  storage_profile_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.disk_type}"
  }

  storage_profile_data_disk {
    lun               = 0
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = "${var.data_disk_size}"
    managed_disk_type = "${var.disk_type}"
  }

  tags = "${var.tags}"
}
