module "lldap" {
  source             = "../lib/terraform/service"
  name               = "lldap"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets = {
    jwt = {
      secret = var.lldap_jwt_secret
    }
    key = {
      seed = var.lldap_key_seed
    }
    user = {
      password = var.lldap_admin_password
    }
  }
}
