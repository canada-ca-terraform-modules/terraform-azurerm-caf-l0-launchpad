output custom_role_definitions {
  value = module.aad_custom_role_definition.custom_role_definitions
}

output azurecaf_naming_convention {
  value = module.aad_custom_role_definition.azurecaf_naming_convention
}

output custom_role {
  value = module.aad_custom_role_definition.custom_role
}

output assignment {
  value = module.aad_custom_role_definition.assignment
}

# output aad_scopes {
#   value = module.aad_custom_role_definition.aad_scopes
# }

# output local_assignments {
#   value = module.aad_custom_role_definition.assignments
# }