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