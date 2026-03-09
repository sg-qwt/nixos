module "az_jerky" {
  source = "./azbase"

  rg_name       = "nixos-jerky"
  region        = "japaneast"
  hostname      = "jerky"
  size          = "Standard_B2als_v2"
  disk_size_gb  = 100
  image_version = azurerm_shared_image_version.nixos20251012.id
  ip_refresh    = "0709"
  zone_id       = local.edg_zone_id
  nsg_rules = {
    transmission-peer = {
      priority = 1001
      protocol = "*"
      port     = local.ports.transmission-peer
    }
    http = {
      priority = 1002
      protocol = "Tcp"
      port     = 80
    }
    https = {
      priority = 1003
      protocol = "Tcp"
      port     = 443
    }
    ssh = {
      priority = 1004
      protocol = "Tcp"
      port     = 22
    }
    anytls = {
      priority = 1005
      protocol = "Tcp"
      port     = local.ports.anytls
    }
  }
}

output "jerky_ipv4" {
  value = module.az_jerky.ipv4
}

output "jerky_ipv6" {
  value = module.az_jerky.ipv6
}
