data "cloudflare_api_token_permission_groups_list" "all" {}

locals {
  zone_read = element(
    data.cloudflare_api_token_permission_groups_list.all.result,
    index(
      data.cloudflare_api_token_permission_groups_list.all.result.*.name,
      "Zone Read"
    )
  )
  dns_write = element(
    data.cloudflare_api_token_permission_groups_list.all.result,
    index(
      data.cloudflare_api_token_permission_groups_list.all.result.*.name,
      "DNS Write"
    )
  )
}

resource "cloudflare_api_token" "cf_acme_token" {
  name = "cf-acme-token"

  policies = [{
    effect = "allow"
    permission_groups = [
      { id = local.zone_read.id },
      { id = local.dns_write.id }
    ]
    resources = {
      "com.cloudflare.api.account.zone.*" = "*"
    }
  }]
}

output "cloudflare_token" {
  value     = cloudflare_api_token.cf_acme_token.value
  sensitive = true
}
