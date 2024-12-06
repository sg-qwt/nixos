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
      name    = "@"
      type    = "A"
      content = module.az_dui.ipv4
    }
    aaaa = {
      name    = "@"
      type    = "AAAA"
      content = module.az_dui.ipv6
    }
    catch = {
      name    = "*"
      type    = "CNAME"
      content = local.fqdn.edg
    }
  }

  allow_overwrite = true
  zone_id         = local.edg_zone_id
  name            = each.value.name
  content         = each.value.content
  type            = each.value.type
  proxied         = false
}

resource "cloudflare_record" "dui_h" {
  name    = "dui.h"
  type    = "A"
  content = module.az_dui.ipv4
  zone_id = local.edg_zone_id
  proxied = false
}

resource "cloudflare_record" "xun_h" {
  name    = "xun.h"
  type    = "A"
  content = module.az_xun.ipv4
  zone_id = local.edg_zone_id
  proxied = false
}

resource "cloudflare_record" "edg_ts_h" {
  for_each = local.ts_nixos_devices
  name     = "${each.key}.h"
  type     = "A"
  content  = each.value
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

