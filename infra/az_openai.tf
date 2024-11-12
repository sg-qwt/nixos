data "azurerm_cognitive_account" "acc" {
  name                = "zaizhiwanwudev"
  resource_group_name = "gptlab"
}

resource "azurerm_cognitive_deployment" "shuqi" {
  name                 = local.openai.deployment
  cognitive_account_id = data.azurerm_cognitive_account.acc.id

  sku {
    name = "Standard"
  }

  model {
    format  = "OpenAI"
    name    = "gpt-4o"
  }
}

output "openai_key" {
  value     = data.azurerm_cognitive_account.acc.primary_access_key
  sensitive = true
}
