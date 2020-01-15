variable "resource_group_name" {
  description = "Name of the resource group in which the Virtual Machine scaleset and the associated resources will be deployed."
  default     = "scaleset-rg"
}

variable "location" {
  description = "Specifies the location where the resources will be deployed.Check the list of locations which support Avaialbility Zones for scaleset here https://docs.microsoft.com/en-us/azure/availability-zones/az-overview"
}

variable "name" {
  description = "Name of Virtual Machine ScaleSet"
  default     = "azvmss"
}

variable "adminUsername" {
  description = "Username for the Virtual Machine"
  default     = "azureuser"
}

variable "adminPassword" {
  description = "Password for the Virtual Machine"
}

variable "sshkeys" {
  description = "Path to SSH public key for authentication in linux"
  default     = "~/.ssh/id_rsa.pub"
}

variable "numberofVMs" {
  description = "Number of VMs to deploy in the Virtual Machine ScaleSet"
  default     = "3"
}

variable "singleplacementgroup" {
  description = "Disable to have cluster of more than 100 VMs"
  default     = "true"
}

variable "zones" {
  description = "Zones to deploy the scaleset VMs"
  default     = [1, 2, 3]
}

variable "lb_sku" {
  description = "Basic or Standard). Needs to be standard if Zones are used or singleplacementgroup is set to false"
  default     = "Standard"
}

variable "disk_type" {
  description = "Disk type to be used for OS and data disks"
  default     = "Standard_LRS"
}

variable "data_disk_size" {
  description = "Disk size for data disks in GB"
  default     = "32"
}

## Variables for VM type and OS
variable "vm_os_publisher" {
  description = "Name of the publisher of the image to be deployed"
  default     = ""
}

variable "vm_os_offer" {
  description = "Name of the offer of the image to be deployed"
  default     = ""
}

variable "vm_os_sku" {
  description = "SKU of the image to be deployed"
  default     = ""
}

variable "vm_os_version" {
  description = "Version of the image to be deployed"
  default     = ""
}

variable "custom_image_id" {
  description = "If custom image is used image id needs to be specified here"
  default     = ""
}

variable "vm_size" {
  description = "Size of the VMs in the scaleset"
  default     = "Standard_DS1_v2"
}

variable "os_type" {
  description = "Variable to check the type of OS. Possible values linux or windows"
}

variable "windows_vm_agent" {
  description = "Flag to enable VM guest agent on Windows VMs"
  default     = "true"
}

variable "windows_auto_upgrade" {
  description = "Enable automatic windows updates"
  default     = "true"
}

## Variable for network and IP configurations ##
variable "vnet_subnet_id" {
  description = "Subnet ID of the VNET where the Virtual Machine ScaleSet will be deployed"
}

variable "publicip_timeout" {
  description = "The idle timeout in minutes. This value must be between 4 and 32"
  default     = "4"
}

variable "publicip_allocation" {
  description = "Public IP allocation method. Needs to be static for Standard SKUs"
  default     = "Static"
}

variable "dns_name" {
  description = "DNS name for the load balancer frontend publicip"
}

variable "accelerated_network" {
  description = "Specifies whether to enable accelerated networking or not."
  default     = "false"
}

variable "ip_forwarding" {
  description = "Specify whether IP forwarding is enabled on this NIC"
  default     = "false"
}

variable "tags" {
  description = "A map of tags to the deployed resources. Empty by default."
  type        = "map"
  default     = {}
}
