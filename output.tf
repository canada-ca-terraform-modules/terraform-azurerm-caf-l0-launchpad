
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

output github_token_keyvault {
  sensitive = true

  value = {
    keyvault_secret_name = azurerm_key_vault_secret.github_pat.name
    keyvault_name        = azurerm_key_vault.keyvault[var.launchpad_key_names.keyvault].name
    keyvault_id          = azurerm_key_vault.keyvault[var.launchpad_key_names.keyvault].id
  }
}

