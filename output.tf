
output aad_apps {
  sensitive = true
  value     = module.azure_applications.aad_apps
}

output global_settings {
  sensitive = true
  value     = local.global_settings
}

output resource_groups {
  sensitive = true
  value     = azurerm_resource_group.rg
}

# Does not work in light mode
output azure_subscriptions {
  sensitive = true
  value     = var.subscriptions
}

output keyvaults {
  sensitive = true
  value     = azurerm_key_vault.keyvault
}

