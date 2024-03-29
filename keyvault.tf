
resource "azurecaf_naming_convention" "keyvault" {
  for_each = var.keyvaults

  name          = each.value.name
  resource_type = "kv"
  convention    = lookup(each.value, "convention", local.global_settings.convention)
  prefix        = lookup(each.value, "useprefix", false) == true ? local.prefix_start_alpha : ""
  max_length    = lookup(each.value, "max_length", null)
}

resource "azurerm_key_vault" "keyvault" {
  for_each = var.keyvaults 

  name                = azurecaf_naming_convention.keyvault[each.key].result
  location            = lookup(each.value, "location", local.global_settings.default_location)
  resource_group_name = azurerm_resource_group.rg[each.value.resource_group_key].name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = each.value.sku_name

  tags = {
    tfstate     = var.level
    environment = local.global_settings.environment
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = var.logged_user_objectId

    key_permissions    = []
    secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
  }

  lifecycle {
    ignore_changes = [
      access_policy
    ]
  }
}

resource "azurerm_key_vault_access_policy" "keyvault_access_policy_L0_owners" {
  for_each = azurerm_key_vault.keyvault 
  
  key_vault_id = each.value.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = module.azuread_groups_L0["L0_Subscription_Owners"].id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Restore", "Backup", "Recover"]
}

resource "azurerm_key_vault_access_policy" "keyvault_access_policy_L0_contributors" {
  for_each = azurerm_key_vault.keyvault 
  
  key_vault_id = each.value.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = module.azuread_groups_L0["L0_Subscription_Owners"].id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Restore", "Backup", "Recover"]
}
