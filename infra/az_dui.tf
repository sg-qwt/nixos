module "az_dui" {
  source = "./azbase"

  rg_name      = "nixos-lab"
  region       = "southeastasia"
  hostname     = "dui"
  size         = "Standard_D2as_v5"
  disk_size_gb = 100
}

resource "azurerm_network_security_rule" "SS" {
  name                        = "SS"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = local.ports.ss1
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.az_dui.rg
  network_security_group_name = module.az_dui.nsg
}

resource "azurerm_network_security_rule" "HTTP" {
  name                        = "HTTP"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 80
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.az_dui.rg
  network_security_group_name = module.az_dui.nsg
}

resource "azurerm_network_security_rule" "HTTPS" {
  name                        = "HTTPS"
  priority                    = 1004
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 443
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.az_dui.rg
  network_security_group_name = module.az_dui.nsg
}

resource "azurerm_network_security_rule" "SSH" {
  name                        = "SSH"
  priority                    = 1005
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.az_dui.rg
  network_security_group_name = module.az_dui.nsg
}

output "dui_ipv4" {
  value = module.az_dui.ipv4
}

output "dui_ipv6" {
  value = module.az_dui.ipv6
}
