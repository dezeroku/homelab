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

module "user" {
  for_each = var.users

  source = "./user"

  userpass_accessor = vault_auth_backend.userpass.accessor
  username          = each.key
  user_password     = each.value.password
  metadata = {
    email = each.value.email
  }
  groups = each.value.groups

  # Single source of truth: derived from the groups declared in groups.tf.
  groups_mapping       = { for name, group in vault_identity_group.this : name => group.id }
  lldap_groups_mapping = { for name, group in lldap_group.this : name => group.id }
}
