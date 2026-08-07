module "jellyfin" {
  source             = "${local.lib_path}/terraform/service"
  name               = "jellyfin"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  namespace = "media"

  secrets = {
    ldap_bind_user = {
      username = lldap_user.jellyfin_bind_user.username
      password = random_password.jellyfin_ldap_sa.result
    }
  }
}

resource "random_password" "jellyfin_ldap_sa" {
  length = 31
}

resource "lldap_user" "jellyfin_bind_user" {
  username = "jellyfin_bind_user"
  email    = "jellyfin@${var.domain}"
  password = random_password.jellyfin_ldap_sa.result
}

data "lldap_group" "lldap_strict_readonly" {
  # TODO: this seems a bit fragile?
  # Any better way to import it?
  id = 3
}

resource "lldap_user_memberships" "jellyfin_bind_user" {
  user_id   = lldap_user.jellyfin_bind_user.id
  group_ids = [data.lldap_group.lldap_strict_readonly.id]
}
