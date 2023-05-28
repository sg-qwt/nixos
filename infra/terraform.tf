terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
    }

    tailscale = {
      source = "tailscale/tailscale"
    }
  }

  backend "azurerm" {
    resource_group_name  = "persistent"
    storage_account_name = "sa25542"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "cloudflare" {}

provider "tailscale" {
  tailnet = "sg-qwt.github"
}
