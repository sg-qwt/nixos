variable "rg_name" {}
variable "region" {}
variable "hostname" {}
variable "size" {}
variable "disk_size_gb" {}
variable "image_version" {}
variable "ip_refresh" {
  description = "Change this to force refresh ip"
  type = string
  default = ""
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.region
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.hostname}-vnet"
  address_space       = ["10.0.0.0/16", "ace:cab:deca::/48"]
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.hostname}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.0.1.0/24", "ace:cab:deca:daed::/64"]
}

resource "azurerm_public_ip" "public_ip_v4" {
  name                = "${var.hostname}${var.ip_refresh}-v4-ip"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_public_ip" "public_ip_v6" {
  name                = "${var.hostname}${var.ip_refresh}-v6-ip"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv6"

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.hostname}-nsg"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.hostname}-nic"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.hostname}-nic-configuration-v4"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_v4.id
    primary                       = true
  }

  ip_configuration {
    name                          = "${var.hostname}-nic-configuration-v6"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv6"
    public_ip_address_id          = azurerm_public_ip.public_ip_v6.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.hostname
  location              = var.region
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.size

  os_disk {
    name                 = "nixos-system"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.disk_size_gb
  }

  source_image_id = var.image_version

  admin_username                  = "me"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "me"
    public_key = file("../resources/keys/ssh-me.pub")
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}

output "rg" {
  value = azurerm_resource_group.rg.name
}

output "nsg" {
  value = azurerm_network_security_group.nsg.name
}

output "ipv4" {
  value = azurerm_public_ip.public_ip_v4.ip_address
}

output "ipv6" {
  value = azurerm_public_ip.public_ip_v6.ip_address
}
