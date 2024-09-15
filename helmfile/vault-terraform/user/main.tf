resource "vault_generic_endpoint" "userpass" {
  path                 = "auth/userpass/users/${var.username}"
  ignore_absent_fields = true
  data_json = jsonencode({
    "token_policies" : ["default"]
    "password" : var.user_password,
  })
}

resource "vault_identity_entity" "user" {
  name     = var.username
  policies = ["default"]
  metadata = var.metadata
}

resource "vault_identity_entity_alias" "alias" {
  name           = var.username
  mount_accessor = var.userpass_accessor
  canonical_id   = vault_identity_entity.user.id
}

// Add every user to the "users" groups by default
resource "vault_identity_group_member_entity_ids" "users_member" {
  member_entity_ids = [vault_identity_entity.user.id]
  exclusive         = false
  group_id          = var.groups_mapping["users"]
}

resource "vault_identity_group_member_entity_ids" "group_member" {
  for_each          = toset(var.groups)
  member_entity_ids = [vault_identity_entity.user.id]
  exclusive         = false
  group_id          = var.groups_mapping[each.value]
}
