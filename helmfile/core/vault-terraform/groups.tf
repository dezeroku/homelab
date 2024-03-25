resource "vault_identity_group" "users" {
  name                       = "users"
  type                       = "internal"
  policies                   = ["default", "oidc-auth"]
  external_member_entity_ids = true
}
