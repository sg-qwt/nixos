provider "azurerm" {
  features {}
}

module "az_dui" {
  source = "./azbase"

  rg_name = "nixos-lab"
  region = "southeastasia"
  hostname = "dui"
  disk_size_gb = 100
}

output "dui_ipv4" {
  value = module.az_dui.ipv4
}

output "dui_ipv6" {
  value = module.az_dui.ipv6
}
