resource "random_string" "unique" {
  length      = 5
  min_numeric = 5
  numeric     = true
  special     = false
  lower       = true
  upper       = false
}

resource "azurerm_resource_group" "anulab" {
  name     = "anulab${random_string.unique.result}"
  location = "Sweden Central"
}

resource "azurerm_cognitive_account" "anu_foundry" {
  name                = "anufoundry${random_string.unique.result}"
  location            = azurerm_resource_group.anulab.location
  resource_group_name = azurerm_resource_group.anulab.name
  kind                = "AIServices"

  identity {
    type = "SystemAssigned"
  }

  sku_name = "S0"

  custom_subdomain_name      = "anufoundry${random_string.unique.result}"
  project_management_enabled = true
}

resource "azurerm_cognitive_deployment" "anu_gpt5_mini" {
  depends_on = [
    azurerm_cognitive_account.anu_foundry
  ]

  name                   = "gpt-5-mini"
  cognitive_account_id   = azurerm_cognitive_account.anu_foundry.id
  rai_policy_name        = "Microsoft.DefaultV2"
  version_upgrade_option = "OnceNewDefaultVersionAvailable"

  sku {
    name     = "GlobalStandard"
    capacity = 200
  }

  model {
    format  = "OpenAI"
    name    = "gpt-5-mini"
    version = "2025-08-07"
  }
}

output "openai_key" {
  value     = azurerm_cognitive_account.anu_foundry.primary_access_key
  sensitive = true
}

output "az_anu_domain" {
  value = azurerm_cognitive_account.anu_foundry.custom_subdomain_name
}
