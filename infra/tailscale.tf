provider "tailscale" {
  tailnet = "sg-qwt.github"
}

locals {
  owner = "sg-qwt@github"
}

resource "tailscale_dns_preferences" "dns" {
  magic_dns = false
}

resource "tailscale_acl" "acl" {
  acl = jsonencode({
    // TagOwner to allow assign tag for each machine.
    "tagOwners" : {
      "tag:nixos" : [
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
    "ssh" : [
      // The default SSH policy, which lets users SSH into devices they own.
      // Learn more at https://tailscale.com/kb/1193/tailscale-ssh/
      {
        "action" : "check",
        "src" : ["autogroup:members"],
        "dst" : ["autogroup:self"],
        "users" : ["autogroup:nonroot", "root"],
      }
    ]
  })
}

resource "tailscale_tailnet_key" "tailnet_key" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  tags          = ["tag:nixos"]
}

output "tailscale_tailnet_key" {
  value     = tailscale_tailnet_key.tailnet_key.key
  sensitive = true
}
