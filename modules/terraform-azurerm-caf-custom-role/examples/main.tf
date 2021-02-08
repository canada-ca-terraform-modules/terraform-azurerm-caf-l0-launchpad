provider "azurerm" {
  features {}
}

module aad_custom_role_definition {
  source = "../"

  custom_role_definitions = local.custom_role_definitions
  prefix                  = local.prefix
  aad_apps                = {}
  subscriptions           = local.subscriptions
}

data "azurerm_subscription" "current" {}
