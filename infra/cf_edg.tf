data "cloudflare_zones" "edg" {
  filter {
    name = local.fqdn.edg
  }
}

locals {
  edg_zone_id = one(data.cloudflare_zones.edg.zones[*].id)
}

resource "cloudflare_record" "root" {
  for_each = {
    a = {
      name  = "@"
      type  = "A"
      value = local.dui_ipv4
    }
    aaaa = {
      name  = "@"
      type  = "AAAA"
      value = local.dui_ipv6
    }
    ooo = {
      name  = "ooo"
      type  = "CNAME"
      value = local.fqdn.edg
    }
  }

  allow_overwrite = true
  zone_id         = local.edg_zone_id
  name            = each.value.name
  value           = each.value.value
  type            = each.value.type
  proxied         = false
}

resource "cloudflare_record" "edg_ts" {
  for_each = local.ts_nixos_devices
  name     = "${each.key}.ts"
  type     = "A"
  value    = each.value
  zone_id  = local.edg_zone_id
  proxied  = false
}

resource "cloudflare_email_routing_settings" "edg" {
  zone_id = local.edg_zone_id
  enabled = true
}

variable "fw_email" { type = string }

resource "cloudflare_email_routing_catch_all" "all" {
  zone_id = local.edg_zone_id
  name    = "forward all"
  enabled = true

  matcher {
    type = "all"
  }

  action {
    type  = "forward"
    value = [var.fw_email]
  }
}

