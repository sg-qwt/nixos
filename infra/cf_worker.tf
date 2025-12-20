data "cloudflare_accounts" "main" {}

variable "gemini_gcp" { }
variable "gemini_apikey" { }

locals {
  cf_account_id = data.cloudflare_accounts.main.result[0].id
}

resource "cloudflare_workers_kv_namespace" "gmkv" {
  account_id = local.cf_account_id
  title      = "GEMINI_CLI_KV"
}

resource "cloudflare_worker" "gemini" {
  account_id = local.cf_account_id
  name = "gemini-cli-worker"
  observability = {
    enabled = true
    logs = {
      enabled = true
    }
  }
  subdomain = {
    enabled = true
    previews_enabled = false
  }
}

resource "cloudflare_worker_version" "gemini" {
  account_id = local.cf_account_id
  worker_id  = cloudflare_worker.gemini.id

  compatibility_date = "2024-09-23"
  compatibility_flags = ["nodejs_compat"]

  main_module = "index.js"

  modules = [
    {
      name         = "index.js"
      content_file = "gemini/index.js"
      content_type = "application/javascript+module"
    }
  ]

  bindings = [
    {
      type         = "kv_namespace"
      name         = "GEMINI_CLI_KV"
      namespace_id = cloudflare_workers_kv_namespace.gmkv.id
    },
    {
      type = "secret_text"
      name = "GCP_SERVICE_ACCOUNT"
      text = var.gemini_gcp
    },
    {
      type = "secret_text"
      name = "OPENAI_API_KEY"
      text = var.gemini_apikey
    },
    {
      type = "plain_text"
      name = "STREAM_THINKING_AS_CONTENT"
      text = "true"
    },
    {
      type = "plain_text"
      name = "ENABLE_AUTO_MODEL_SWITCHING"
      text = "true"
    }
  ]
}

resource "cloudflare_workers_deployment" "gemini" {
  account_id  = local.cf_account_id
  script_name = cloudflare_worker.gemini.name

  strategy = "percentage"

  versions = [
    {
      version_id = cloudflare_worker_version.gemini.id
      percentage = 100
    }
  ]
}

resource "cloudflare_workers_custom_domain" "gemini" {
  account_id  = local.cf_account_id
  zone_id = local.edg_zone_id
  hostname = "gemini.${local.edg_domain}"
  service = cloudflare_worker.gemini.name
}
