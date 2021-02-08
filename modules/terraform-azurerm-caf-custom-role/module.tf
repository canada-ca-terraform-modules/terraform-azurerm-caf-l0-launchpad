locals {

  # Add missing attributes
  custom_role_definitions = {
    for key, custom_role_definition in var.custom_role_definitions : key => merge(var.custom_role_definition, custom_role_definition)
  }

  role_definitions = {
    for custom_role_definition in
    flatten(
      [
        for key, role in local.custom_role_definitions :
        [
          for subscription_key, aad_app_keys in role.mapping_subscription_key_to_azure_app_keys : {
            # Resolve the object. Note only one key is required. if both are set subscriptions_key is used
            # scope = {
            #   subscription_key = "es-level0-security"
            #   explicit_scope = "/subscriptions/fed745fc-818a-4b9f-8338-22368e098c5c"
            # }
            name             = role.name
            convention       = role.convention
            useprefix        = role.useprefix
            description      = role.description
            permissions      = role.permissions
            scope            = subscription_key == "logged_in_subscription" ? format("/subscriptions/%s", data.azurerm_subscription.primary.subscription_id) : format("/subscriptions/%s", var.subscriptions[subscription_key].subscription_id)
            role_key         = "${key}-to-${subscription_key}"
            aad_app_keys     = aad_app_keys
            subscription_key = subscription_key
          }
        ]
      ]
    ) : custom_role_definition.role_key => custom_role_definition
    # Produces:
    # aad_scopes = {
    #   "caf-launchpad-rwdo" = {
    #     "scope" = "/subscriptions/fed745fc-818a-4b9f-8338-22368e098c5d"
    #     "role_key" = "caf-launchpad-rwdo"
    #     "aad_app"  = "caf_launchpad"
    #      ...
    #   }
    # }
  }

  role_assignments = {
    for custom_role_definition in
    flatten(
      [
        for key, role in local.custom_role_definitions :
        [
          for subscription_key, aad_app_keys in role.mapping_subscription_key_to_azure_app_keys : [
            for aad_app_key in aad_app_keys : {
              scope                = subscription_key == "logged_in_subscription" ? format("/subscriptions/%s", data.azurerm_subscription.primary.subscription_id) : format("/subscriptions/%s", var.subscriptions[subscription_key].subscription_id)
              role_key             = "${key}-to-${subscription_key}"
              aad_app_sp_object_id = var.aad_apps[aad_app_key].azuread_service_principal.object_id
              assignment_key       = "${key}-to-${subscription_key}-to-${aad_app_key}"
            }
          ]
        ]
      ]
    ) : custom_role_definition.assignment_key => custom_role_definition
    # Produces:
    # aad_scopes = {
    #   "caf-launchpad-rwdo" = {
    #     "scope" = "/subscriptions/fed745fc-818a-4b9f-8338-22368e098c5d"
    #     "role_key" = "caf-launchpad-rwdo"
    #     "aad_app"  = "caf_launchpad"
    #      ...
    #   }
    # }
  }

}

resource "azurecaf_naming_convention" "custom_role" {
  for_each = local.role_definitions

  name          = each.value.role_key
  prefix        = each.value.useprefix ? var.prefix : ""
  resource_type = "rg" # workaround to keep the dashes
  convention    = each.value.convention
}

resource "azurerm_role_definition" "custom_role" {
  for_each = local.role_definitions

  name = azurecaf_naming_convention.custom_role[each.key].result

  scope       = each.value.scope
  description = each.value.description

  permissions {
    actions          = lookup(each.value.permissions, "actions", [])
    not_actions      = lookup(each.value.permissions, "not_actions", [])
    data_actions     = lookup(each.value.permissions, "data_actions", [])
    not_data_actions = lookup(each.value.permissions, "not_data_actions", [])
  }

  assignable_scopes = [each.value.scope]

}


resource "azurerm_role_assignment" "assignment" {
  for_each = local.role_assignments

  scope              = each.value.scope
  role_definition_id = azurerm_role_definition.custom_role[each.value.role_key].id
  principal_id       = each.value.aad_app_sp_object_id
}
