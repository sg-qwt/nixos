resource "grafana_cloud_stack" "main" {
  provider = grafana.cloud

  name        = "qtlab"
  slug        = "qtlab"
  region_slug = "prod-ap-southeast-1"
}

resource "grafana_cloud_stack_service_account" "sa" {
  provider   = grafana.cloud
  stack_slug = grafana_cloud_stack.main.slug

  name        = "main stack service account"
  role        = "Admin"
  is_disabled = false
}

resource "grafana_cloud_stack_service_account_token" "main" {
  provider   = grafana.cloud
  stack_slug = grafana_cloud_stack.main.slug

  name               = "main stack key"
  service_account_id = grafana_cloud_stack_service_account.sa.id
}

provider "grafana" {
  alias = "qtlab"

  url  = grafana_cloud_stack.main.url
  auth = grafana_cloud_stack_service_account_token.main.key
}
