provider "cloudflare" {}

data "cloudflare_api_token_permission_groups" "all" {}

resource "cloudflare_api_token" "cf_acme_token" {
  name = "cf-acme-token"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.zone["Zone Read"],
      data.cloudflare_api_token_permission_groups.all.zone["DNS Write"],
    ]
    resources = {
      "com.cloudflare.api.account.zone.*" = "*"
    }
  }
}

output "cloudflare_token" {
  value = cloudflare_api_token.cf_acme_token.value
  sensitive = true
}
