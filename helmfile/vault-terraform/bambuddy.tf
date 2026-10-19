module "bambuddy" {
  source             = "${local.lib_path}/terraform/service"
  name               = "bambuddy"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  backuper_credentials_path = local.backuper_credentials_path

  oidc = {
    redirect_uris = ["https://bambuddy.${var.domain}/api/v1/auth/oidc/callback"]
    group_ids     = [vault_identity_group.this["bambuddy"].id]
  }
}
