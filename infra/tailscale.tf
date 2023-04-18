provider "tailscale" {
  tailnet = "sg-qwt.github"
}

locals {
  owner        = "sg-qwt@github"
  tailnet_name = "tail2b3a2.ts.net"
  nixos_tag    = "tag:nixos"
}

resource "tailscale_dns_preferences" "dns" {
  magic_dns = false
}

resource "tailscale_acl" "acl" {
  acl = jsonencode({
    // TagOwner to allow assign tag for each machine.
    "tagOwners" : {
      "${local.nixos_tag}" : [
        local.owner
      ]
    }
    "acls" : [
      {
        action = "accept",
        users  = ["*"],
        ports  = ["*:*"],
      }
    ]
  })
}

resource "tailscale_tailnet_key" "tailnet_key" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  tags          = [local.nixos_tag]
}

data "tailscale_devices" "all" {
}

output "tailscale_tailnet_key" {
  value     = tailscale_tailnet_key.tailnet_key.key
  sensitive = true
}

locals {
  ts_nixos_devices = {
    for device in data.tailscale_devices.all.devices :
    trimsuffix(device.name, ".${local.tailnet_name}") => device.addresses[0]
    if contains(device.tags, local.nixos_tag)
  }
}
