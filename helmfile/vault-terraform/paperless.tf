module "paperless_ses_incoming" {
  source = "git@github.com:dezeroku/ses_local_email.git//terraform?depth=1&ref=v0.5.2"

  recipients    = var.paperless_ses_incoming_recipients
  senders_regex = var.paperless_ses_senders_regex
}

module "paperless" {
  source             = "./service"
  name               = "paperless"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  include_backuper_credentials = true

  oidc = {
    redirect_uris = ["https://paperless.${var.domain}/accounts/oidc/vault/login/callback/"]
    group_ids     = [vault_identity_group.this["paperless"].id]
  }

  secrets = {
    "secret-key" = {
      key = var.paperless_secret_key
    }
    "admin" = {
      username = var.paperless_admin_username
      password = var.paperless_admin_password
      email    = var.paperless_admin_email
    }
    "ses/incoming" = {
      queue_url             = module.paperless_ses_incoming.queue_url
      bucket_name           = module.paperless_ses_incoming.bucket_name
      aws_access_key_id     = module.paperless_ses_incoming.user_access_key
      aws_secret_access_key = module.paperless_ses_incoming.user_secret_key
    }
    # TODO: this is currently not used by the app
    "smtp" = {
      username = var.ses_smtp_username
      password = var.ses_smtp_password
      host     = var.ses_smtp_host
    }
  }
}

moved {
  from = vault_identity_oidc_assignment.paperless
  to   = module.paperless.vault_identity_oidc_assignment.this[0]
}

moved {
  from = vault_identity_oidc_client.paperless
  to   = module.paperless.vault_identity_oidc_client.this[0]
}

moved {
  from = vault_kubernetes_auth_backend_role.paperless
  to   = module.paperless.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.paperless
  to   = module.paperless.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.paperless-secret-key
  to   = module.paperless.vault_generic_secret.this["secret-key"]
}

moved {
  from = vault_generic_secret.paperless-admin
  to   = module.paperless.vault_generic_secret.this["admin"]
}

moved {
  from = vault_generic_secret.paperless-redis
  to   = module.paperless.vault_generic_secret.this["redis"]
}

moved {
  from = vault_generic_secret.paperless-ses-incoming
  to   = module.paperless.vault_generic_secret.this["ses/incoming"]
}

moved {
  from = vault_generic_secret.paperless-smtp
  to   = module.paperless.vault_generic_secret.this["smtp"]
}
