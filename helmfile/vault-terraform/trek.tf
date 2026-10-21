module "trek" {
  source             = "${local.lib_path}/terraform/service"
  name               = "trek"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  backuper_credentials_path = local.backuper_credentials_path

  oidc = {
    redirect_uris = ["https://trek.${var.domain}/api/auth/oidc/callback"]
    group_ids     = [vault_identity_group.this["trek"].id]
  }

  secrets = {
    encryption-key = {
      value = random_bytes.trek_encryption_key.hex
    }
  }
}

resource "random_bytes" "trek_encryption_key" {
  length = 32

  # Prevents regeneration unless you deliberately bump this
  keepers = {
    version = 1
  }
}
