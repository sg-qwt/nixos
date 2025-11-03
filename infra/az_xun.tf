module "az_xun" {
  source = "./azbase"

  rg_name       = "nixos-netbox-hk"
  region        = "eastasia"
  hostname      = "xun"
  size          = "Standard_B1ms"
  disk_size_gb  = 20
  image_version = azurerm_shared_image_version.nixos20251012.id
}

resource "azurerm_shared_image_version" "nixos20251012" {
  name                                     = "0.0.2"
  gallery_name                             = azurerm_shared_image.nixos.gallery_name
  image_name                               = azurerm_shared_image.nixos.name
  resource_group_name                      = azurerm_shared_image.nixos.resource_group_name
  location                                 = azurerm_shared_image.nixos.location
  blob_uri                                 = data.azurerm_storage_blob.image_vhd_20251012.id
  storage_account_id                       = data.azurerm_storage_account.persist.id
  deletion_of_replicated_locations_enabled = true

  target_region {
    name                   = "southeastasia"
    regional_replica_count = 1
    storage_account_type   = "Standard_LRS"
  }

  target_region {
    name                   = "eastasia"
    regional_replica_count = 1
    storage_account_type   = "Standard_LRS"
  }
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

resource "azurerm_network_security_rule" "SSTLS_xun" {
  name                        = "SSTLS"
  priority                    = 1006
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = local.ports.sstls
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
