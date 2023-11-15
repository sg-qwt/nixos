data "azurerm_cognitive_account" "acc" {
  name                = "zaizhiwanwudev"
  resource_group_name = "gptlab"
}

resource "azurerm_cognitive_deployment" "shuqi" {
  name                 = local.openai.deployment
  cognitive_account_id = data.azurerm_cognitive_account.acc.id

  model {
    format  = "OpenAI"
    name    = "gpt-4"
    version = "0613"
  }

  scale {
    type = "Standard"
  }
}

output "openai_key" {
  value     = data.azurerm_cognitive_account.acc.primary_access_key
  sensitive = true
}
