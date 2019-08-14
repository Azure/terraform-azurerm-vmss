[![Build Status](https://dev.azure.com/kavenka/terraform-azure-scalesets/_apis/build/status/karthikvenkat17.terraform-azurerm-scalesets?branchName=master)](https://dev.azure.com/kavenka/terraform-azure-scalesets/_build/latest?definitionId=1&branchName=master)
# terraform-azurerm-scalesets
## Terraform Azure RM Virtual Machine ScaleSets module

This Terraform module deploys the following : 
- Virtual Machine scalesets across Availability Zones with a default count of 3 based on Windows or Linux, standard or custom images
- Network Security Group with default inbound rule to allow remote access to the VMs (port 22 or 3389) 
- Standard load balancer with the scaleset VMs added to the backend pool

## Simple Usage

Code block deploys VM scalesets across the AV zones based on the latest version of Ubuntu 18.04-LTS image. 

```hcl
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
  source              = "Azure/scalesets/azurerm"
  location            = "WestEurope"
  adminPassword       = "azvmss@123456"
  os_type             = "linux"
  dns_name            = "lbvmsslinux"
  vnet_subnet_id      = "${azurerm_subnet.mytfsubnet.id}"
}
```
Code block deploys VM scalesets across the AV zones based on the latest version of Windows Server 2016 image. 

```hcl
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
```
## Advanced usage
To create a scaleset with standard image OS publisher, offer, SKU and version needs to be specified. For custom images, image id needs to be specified. 

## Test

### Configurations

- [Configure Terraform for Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)

We provide 2 ways to build, run, and test the module on a local development machine.  [Native (Mac/Linux)](#native-maclinux) or [Docker](#docker).

### Native(Mac/Linux)

#### Prerequisites

- [Terraform **(~> 0.11.7)**](https://www.terraform.io/downloads.html)
- [Golang **(~> 1.10.3)**](https://golang.org/dl/)

#### Environment setup

We provide simple script to quickly set up module development environment:

```sh
$ curl -sSL https://raw.githubusercontent.com/Azure/terramodtest/master/tool/env_setup.sh | sudo bash
```

#### Run test

Then simply run it in local shell:

```sh
$ cd $GOPATH/src/{directory_name}/
$ ./test.sh full
```

### Docker

We provide a Dockerfile to build a new image based `FROM` the `microsoft/terraform-test` Docker hub image which adds additional tools / packages specific for this module.

#### Prerequisites

- [Docker](https://www.docker.com/community-edition#/download)

#### Build the image

```sh
$ docker build -t terraform-azurerm-scalesets .
```

#### Run test (Docker)

This runs the local validation:

```sh
$ docker run --rm terraform-azurerm-scalesets /bin/bash -c "./test.sh validate"
```

This runs the full tests (deploys resources into your Azure subscription):

```sh
$ docker run -e "ARM_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID" -e "ARM_CLIENT_ID=$AZURE_CLIENT_ID" -e "ARM_CLIENT_SECRET=$AZURE_CLIENT_SECRET" -e "ARM_TENANT_ID=$AZURE_TENANT_ID" -e "ARM_TEST_LOCATION=WestEurope" -e "ARM_TEST_LOCATION_ALT=NorthEurope" --rm terraform-azurerm-scalesets bash -c "./test.sh full"
```
## License

[MIT](LICENSE)

# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
