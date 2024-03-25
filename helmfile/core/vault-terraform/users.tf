# Define userpass auth method and users
resource "vault_auth_backend" "userpass" {
  type = "userpass"

  # oidc-auth is defined in oidc.tf
  tune {
    default_lease_ttl  = "1h"
    max_lease_ttl      = "1h"
    listing_visibility = "unauth"
  }
}

resource "vault_generic_endpoint" "userpass_dezeroku" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/${var.user_dezeroku_username}"
  ignore_absent_fields = true
  data_json = jsonencode({
    "token_policies" : ["default"]
    "password" : var.user_dezeroku_password,
  })
}

resource "vault_identity_entity" "dezeroku" {
  name     = var.user_dezeroku_username
  policies = ["default"]
  metadata = {
    email = "dezeroku@gmail.com"
  }
}

resource "vault_identity_entity_alias" "test" {
  name           = var.user_dezeroku_username
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.dezeroku.id
}

resource "vault_identity_group_member_entity_ids" "users_dezeroku" {
  member_entity_ids = [vault_identity_entity.dezeroku.id]
  exclusive         = false
  group_id          = vault_identity_group.users.id
}
