output custom_role_definitions {
  value = local.custom_role_definitions
}

output azurecaf_naming_convention {
  value = azurecaf_naming_convention.custom_role
}

output custom_role {
  value = azurerm_role_definition.custom_role
}

output assignment {
  value = azurerm_role_assignment.assignment
}

# output aad_scopes {
#   value = local.aad_scopes
# }

# output assignments {
#   value = local.aad_scopes
# }
