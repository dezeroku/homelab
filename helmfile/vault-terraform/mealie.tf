module "mealie" {
  source             = "${local.lib_path}/terraform/service"
  name               = "mealie"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  backuper_credentials_path = local.backuper_credentials_path

  oidc = {
    redirect_uris = ["https://mealie.${var.domain}/login"]
    group_ids     = [vault_identity_group.this["mealie"].id]
  }
}
