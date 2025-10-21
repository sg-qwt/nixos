variable "rg_name" {}
variable "region" {}
variable "hostname" {}
variable "size" {}
variable "disk_size_gb" {}
variable "image_version" {}
variable "ip_refresh" {
  description = "Change this to force refresh ip"
  type        = string
  default     = ""
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
    username = "me"
    # no longer used
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZI2D+3uQ1sKAttjgNyk0A/E/KhJiGHfHAlAa8gOvS+VNVeBm7grDPP2DDMRcwS0HT7hbXY3v+L5zplnDXCMRNmXdnJVg4wDbxt6HbtJm2o3QJAqj7njPFn7FcG8B5yvgwIWzsl3nYO9n+UPL/f/WDVWEYQGUW5xrA+/n07zEFeFGQAE4F3i/qGWn8kSqIXPYz1aaBLqN+9+6pAVuf6dDWSdqRnGJEymsO1mVvprrjlU3Wja+pA/JIT28pVqqKWk/R20rJUm2eT1WIceHo+PlBW/8kz/YJUhzAOgu2iqolkrJng6HFNBKdhq/sC9PLcbrml3hx8peFahRSxqnz8//D20NBzDjk6ThJAEZOYw9tlJxQexsDDP1pgtB1TZI+GS+7z9LdUV+MJjP6po46EX/qG2fm7XHKPl5vBDO0+lxEDqrIUftAv3tEtlhqbVDcPx+0MxH3UGd3b2UwuvB0CYckHvj2TRAh2PuH4TMGTZrbRy5RdwvsObg6ijOOlM1eQWNv/LjjXRz8SYd1pReSjZhywFcmUDyJcEAgi7C4wTKxzCuO1lkcTs3l2/n+dvy4J4izDGEkbZHvWStJ0tqe0oXb9KoCONyFAMmtsmYQCtXaaXa1uDmOcAUEk256aD5vDzmzUafewOqTxr492ZAQ3RBmWqphabJeuMP7Jw3z/keWpQ== cardno:18 182 344"
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
