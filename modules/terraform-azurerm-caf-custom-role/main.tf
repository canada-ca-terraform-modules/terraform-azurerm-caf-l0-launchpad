provider azurerm {
  features {}
}

terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
  }
}


data "azurerm_subscription" "primary" {}
