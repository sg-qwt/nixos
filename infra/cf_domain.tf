variable "fw_email" { type = string }
variable "fqdn_edg" { type = string }
variable "fqdn_cybcc" { type = string }

data "cloudflare_zone" "edg" {
  filter = {
    name = var.fqdn_edg
  }
}

data "cloudflare_zone" "cybcc" {
  filter = {
    name = var.fqdn_cybcc
  }
}

locals {
  edg_zone_id   = data.cloudflare_zone.edg.zone_id
  edg_domain    = data.cloudflare_zone.edg.name
  cybcc_zone_id = data.cloudflare_zone.cybcc.zone_id
  cybcc_domain  = data.cloudflare_zone.cybcc.name
}

resource "cloudflare_dns_record" "edg" {
  for_each = {
    a = {
      name    = "@"
      type    = "A"
      content = module.az_jerky.ipv4
    }
    aaaa = {
      name    = "@"
      type    = "AAAA"
      content = module.az_jerky.ipv6
    }
    catch = {
      name    = "*"
      type    = "CNAME"
      content = local.edg_domain
    }
  }

  zone_id = local.edg_zone_id
  name    = each.value.name
  content = each.value.content
  type    = each.value.type
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "cybcc" {
  for_each = {
    a = {
      name    = "@"
      type    = "A"
      content = module.az_puer.ipv4
    }
    aaaa = {
      name    = "@"
      type    = "AAAA"
      content = module.az_puer.ipv6
    }
    catch = {
      name    = "*"
      type    = "CNAME"
      content = local.cybcc_domain
    }
  }

  zone_id = local.cybcc_zone_id
  name    = each.value.name
  content = each.value.content
  type    = each.value.type
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "edg_ts_h" {
  for_each = local.ts_nixos_devices
  name     = "${each.key}.h"
  type     = "A"
  content  = each.value
  zone_id  = local.edg_zone_id
  proxied  = false
  ttl      = 1
}

resource "cloudflare_email_routing_settings" "edg" {
  zone_id = local.edg_zone_id
}


resource "cloudflare_email_routing_catch_all" "all" {
  zone_id = local.edg_zone_id
  name    = "forward all"
  enabled = true

  matchers = [{
    type = "all"
  }]

  actions = [{
    type  = "forward"
    value = [var.fw_email]
  }]
}

output "fqdn" {
  value = {
    edg   = local.edg_domain
    cybcc = local.cybcc_domain
  }
}
