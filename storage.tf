
resource "azurecaf_naming_convention" "stg" {

  name          = var.storage_account_name
  resource_type = "azurerm_storage_account"
  convention    = local.global_settings.convention
  prefix        = local.prefix
}


resource "azurerm_storage_account" "stg" {

  name                     = azurecaf_naming_convention.stg.result
  resource_group_name      = azurerm_resource_group.rg["tfstate"].name
  location                 = azurerm_resource_group.rg["tfstate"].location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  min_tls_version          = "TLS1_2"

  tags = {
    tfstate     = var.level
    environment = local.global_settings.environment
    launchpad   = var.launchpad_mode
  }

  lifecycle {
    ignore_changes = [
      tags.launchpad
    ]
  }
}

resource "null_resource" "set_versionning" {
  depends_on = [azurerm_storage_account.stg]

  provisioner "local-exec" {
    command     = "${path.module}/scripts/set_version.sh"
    interpreter = ["/bin/sh"]
    on_failure  = fail

    environment = {
      RESSOURCE_GROUP_NAME = azurerm_storage_account.stg.resource_group_name
      STORAGEACCOUNT_NAME  = azurerm_storage_account.stg.name
    }
  }
}

resource "azurerm_storage_container" "launchpad" {
  name                  = "level0"
  storage_account_name  = azurerm_storage_account.stg.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "role1_current_user" {
  scope                = azurerm_resource_group.rg["tfstate"].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.logged_user_objectId

  lifecycle {
    ignore_changes = [
      principal_id
    ]
  }
}