module "outline" {
  source             = "${local.lib_path}/terraform/service"
  name               = "outline"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  backuper_credentials_path = local.backuper_credentials_path

  oidc = {
    redirect_uris = ["https://outline.${var.domain}/auth/oidc.callback"]
    group_ids     = [vault_identity_group.this["outline"].id]
  }

  secrets = {
    secret-key = {
      value = random_bytes.outline_secret_key.hex
    }
    utils-secret = {
      value = random_bytes.outline_utils_secret.hex
    }
  }
}

resource "random_bytes" "outline_secret_key" {
  length = 32

  # Prevents regeneration unless you deliberately bump this
  keepers = {
    version = 1
  }
}

resource "random_bytes" "outline_utils_secret" {
  length = 32

  # Prevents regeneration unless you deliberately bump this
  keepers = {
    version = 1
  }
}
