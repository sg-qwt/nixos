resource "azurerm_resource_group" "ailab" {
  name     = "ailab"
  location = "eastus"
}

resource "azurerm_cognitive_account" "boyi" {
  name                = local.openai.account
  location            = azurerm_resource_group.ailab.location
  resource_group_name = azurerm_resource_group.ailab.name
  kind                = "OpenAI"
  sku_name            = "S0"
}

resource "azurerm_cognitive_deployment" "shuqi" {
  name                 = local.openai.deployment
  cognitive_account_id = azurerm_cognitive_account.boyi.id

  model {
    format  = "OpenAI"
    name    = "gpt-35-turbo"
    version = "0613"
  }

  scale {
    type = "Standard"
  }
}

output "openai_key" {
  value     = azurerm_cognitive_account.boyi.primary_access_key
  sensitive = true
}
