locals {
  azuread_groupsMap = {
    L0_Subscription_Owners = {
      userDefinedString = "${var.group}_${var.project}_L0_Subscription_Owners"
      owners            = var.L0_RBAC.ownerNames
    },
    L0_Subscription_Contributors = {
      userDefinedString = "${var.group}_${var.project}_L0_Subscription_Contributors"
      owners            = var.L0_RBAC.contributorNames
    },
  }
}

module azuread_groups_L0 {
  source = "github.com/canada-ca-terraform-modules/terraform-azuread-caf-azuread_group?ref=v1.1.1"
  for_each = local.azuread_groupsMap

  env    = var.env
  userDefinedString = each.value.userDefinedString
  owners = each.value.owners
}

# Adding members to groups

data "azuread_users" "L0_Subscription_Owners" {
  user_principal_names = var.L0_RBAC.ownerNames
}

data "azuread_users" "L0_Subscription_Contributors" {
  user_principal_names = var.L0_RBAC.contributorNames
}

resource "azuread_group_member" "L0_Subscription_Owners-Members" {
  for_each = toset(data.azuread_users.L0_Subscription_Owners.object_ids)

  group_object_id  = module.azuread_groups_L0.L0_Subscription_Owners.id
  member_object_id = each.key
}

resource "azuread_group_member" "L0_Subscription_Contributors-Members" {
  for_each = toset(data.azuread_users.L0_Subscription_Contributors.object_ids)

  group_object_id  = module.azuread_groups_L0.L0_Subscription_Contributors.id
  member_object_id = each.key
}