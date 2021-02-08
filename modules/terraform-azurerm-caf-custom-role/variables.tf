variable subscriptions {
  description = "Map of subscriptions"
}

variable aad_apps {
  description = "Map of aad_app objects that could be associated to a subscription"
}

variable custom_role_definitions {
  description = "Map of custom_role_definition object as defined in the custom_role_definition"
}

variable custom_role_definition {
  type = object({
    name        = string
    convention  = string
    description = string
    useprefix   = bool
    scope = object({
      subscriptions_keys = string
      explicit_scope     = string
    })
    assignable_scopes = list(string)
    permissions = object({
      actions          = list(string)
      not_actions      = list(string)
      data_actions     = list(string)
      not_data_actions = list(string)
    })
    mapping_subscription_key_to_azure_app_keys = map(string)
  })

  default = {
    name        = ""
    convention  = "cafrandom"
    description = ""
    useprefix   = false
    scope = {
      subscriptions_keys = ""
      explicit_scope     = ""
    }
    assignable_scopes = []
    permissions = {
      actions          = []
      not_actions      = ["*"]
      data_actions     = []
      not_data_actions = []
    }
    mapping_subscription_key_to_azure_app_keys = {}
  }
}

variable prefix {
  default = ""
}

