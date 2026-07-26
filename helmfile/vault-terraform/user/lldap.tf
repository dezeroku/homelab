resource "lldap_user" "user" {
  username = var.username
  email    = var.metadata.email
  password = var.user_password
  # display_name = var.username
}

resource "lldap_user_memberships" "user" {
  user_id   = lldap_user.user.id
  group_ids = toset([for group in var.groups : var.lldap_groups_mapping[group]])
}
