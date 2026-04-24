locals {
  az_shared_image_location = "southeastasia"

  az_vms = [
    {
      name         = "puer"
      region       = "southeastasia"
      size         = "Standard_B2ats_v2"
      disk_size_gb = 8
      zone_id      = local.edg_zone_id
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
    },

    {
      name         = "rocky"
      region       = "northeurope"
      size         = "Standard_B2als_v2"
      disk_size_gb = 100
      ip_refresh   = "0709"
      zone_id      = local.edg_zone_id
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
    },
  ]

  az_vms_by_name = {
    for vm in local.az_vms : vm.name => vm
  }

  az_image_target_regions = distinct(concat(
    [local.az_shared_image_location],
    [for vm in local.az_vms : vm.region],
  ))
}

module "az" {
  for_each = local.az_vms_by_name
  source   = "./azbase"

  rg_name       = "nixos-${each.value.name}"
  region        = each.value.region
  hostname      = each.value.name
  size          = each.value.size
  disk_size_gb  = each.value.disk_size_gb
  image_version = azurerm_shared_image_version.nixos20251012.id
  ip_refresh    = try(each.value.ip_refresh, "")
  zone_id       = each.value.zone_id
  nsg_rules     = each.value.nsg_rules
}

output "az_ips" {
  value = {
    for name, vm in module.az : name => {
      ipv4 = vm.ipv4
      ipv6 = vm.ipv6
    }
  }
}
