module "az_puer" {
  source = "./azbase"

  rg_name       = "nixos-puer"
  region        = "southeastasia"
  hostname      = "puer"
  size          = "Standard_B2ats_v2"
  disk_size_gb  = 8
  image_version = azurerm_shared_image_version.nixos20251012.id
  zone_id       = local.edg_zone_id
  nsg_rules = {
    sstls = {
      priority = 1001
      protocol = "Tcp"
      port     = local.ports.sstls
    }
    ssh = {
      priority = 1002
      protocol = "Tcp"
      port     = 22
    }
  }
}

output "puer_ipv4" {
  value = module.az_puer.ipv4
}

output "puer_ipv6" {
  value = module.az_puer.ipv6
}
