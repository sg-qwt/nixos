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

data "tailscale_devices" "all" {
}

locals {
  ts_nixos_devices = {
    for device in data.tailscale_devices.all.devices :
    trimsuffix(device.name, ".${local.tailnet_name}") => device.addresses[0]
    if contains(device.tags, local.nixos_tag)
  }
}
