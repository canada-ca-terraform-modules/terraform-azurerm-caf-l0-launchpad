
locals {
  prefix = "xdcf"

  subscriptions = {
    current = {
      subscription_name    = data.azurerm_subscription.current.display_name
      subscription_id      = data.azurerm_subscription.current.subscription_id
      tenant_name          = "yourtenant.onmicrosoft.com"
      tenant_id            = data.azurerm_subscription.current.tenant_id
      role_definition_name = "Owner"
      aad_app_key          = "caf_launchpad"
    }
  }

  custom_role_definitions = {
    caf-launchpad-rwdo = {
      name        = "caf-landingzone-rwdo"
      convention  = "passthrough"
      useprefix   = true
      description = "Provide addition permissions on top of built-in Contributor role to manage landing zones deployment"
      permissions = {
        actions = [
          "Microsoft.Authorization/roleAssignments/delete",
          "Microsoft.Authorization/roleAssignments/read",
          "Microsoft.Authorization/roleAssignments/write",
          "Microsoft.Authorization/roleDefinitions/write",
          "Microsoft.Authorization/roleDefinitions/delete"
        ]
      }

      scope = {
        subscription_key = "current"
        # explicit_scope = "subscriptions/GUID"
      }

      assignable_scopes = [
        # "subscriptions/GUID/resourcegroup/rg"
      ]

      subscription_key_aad_app_key_assignment = {
        "current" = "caf-launchpad-rwdo"
      }

    }

    caf-launchpad-read = {
      name       = "caf-landingzone-read"
      convention = "passthrough"
      useprefix  = true
      permissions = {
        actions = [
          "Microsoft.Authorization/roleAssignments/read",
        ]
      }

      scope = {
        subscription_key = "current"
        # explicit_scope = ""
      }
    }
  }
}
