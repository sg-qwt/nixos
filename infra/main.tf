provider "azurerm" {
  features {}
}

variable "region" {
  default = "southeastasia"
}

data "azurerm_storage_account" "persist" {
  name                = "sa25542"
  resource_group_name = "persistent"
}

data "azurerm_storage_blob" "image_vhd" {
  name                   = "nixos.vhd"
  storage_account_name   = data.azurerm_storage_account.persist.name
  storage_container_name = "vhds"
}

resource "azurerm_resource_group" "rg" {
  name     = "nixos-lab"
  location = var.region
}

resource "azurerm_virtual_network" "vnet" {
  name                = "dui-vnet"
  address_space       = ["10.0.0.0/16", "ace:cab:deca::/48"]
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "dui-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes     = ["10.0.1.0/24","ace:cab:deca:daed::/64"]
}

resource "azurerm_public_ip" "public_ip_v4" {
  name                = "dui-v4-ip"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
}

resource "azurerm_public_ip" "public_ip_v6" {
  name                = "dui-v6-ip"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv6"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "dui-nsg"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "dui-nic"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "dui-nic-configuration-v4"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_v4.id
    primary                       = true
  }

  ip_configuration {
    name                          = "dui-nic-configuration-v6"
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

resource "azurerm_image" "nixos_image" {
  name                = "nixos-image"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  hyper_v_generation  = "V2"

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = data.azurerm_storage_blob.image_vhd.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "dui"
  location              = var.region
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_D2s_v3"

  os_disk {
    name                 = "nixos-system"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 20
  }

  source_image_id = azurerm_image.nixos_image.id

  admin_username                  = "me"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "me"
    public_key =  file("../resources/keys/ssh-me.pub")
  }

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.persist.primary_blob_endpoint
  }
}
