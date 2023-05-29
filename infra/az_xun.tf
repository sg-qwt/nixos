module "az_xun" {
  source = "./azbase"

  rg_name       = "nixos-netbox"
  region        = "uksouth"
  hostname      = "xun"
  size          = "Standard_B1ms"
  disk_size_gb  = 20
  image_version = azurerm_shared_image_version.nixos.id
}

resource "azurerm_network_security_rule" "SSH_xun" {
  name                        = "SSH"
  priority                    = 1005
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.az_xun.rg
  network_security_group_name = module.az_xun.nsg
}

output "xun_ipv4" {
  value = module.az_xun.ipv4
}

output "xun_ipv6" {
  value = module.az_xun.ipv6
}
