module "paperless_ses_incoming" {
  source = "git@github.com:dezeroku/ses_local_email.git//terraform?depth=1&ref=v0.3.1"

  recipients = var.paperless_ses_incoming_recipients
}

resource "vault_identity_oidc_assignment" "paperless" {
  name = "paperless"
  group_ids = [
    vault_identity_group.paperless.id,
  ]
}

resource "vault_identity_oidc_client" "paperless" {
  name = "paperless"
  redirect_uris = [
    "https://paperless.${var.domain}/accounts/oidc/vault/login/callback/"
  ]
  assignments      = [vault_identity_oidc_assignment.paperless.name]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

resource "vault_kubernetes_auth_backend_role" "paperless" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "paperless"
  bound_service_account_namespaces = ["paperless"]
  token_ttl                        = 3600
  bound_service_account_names      = ["paperless"]
  token_policies                   = ["paperless"]
}

resource "vault_policy" "paperless" {
  name = "paperless"

  policy = <<EOT
path "kvv2/data/services/paperless/secret-key" {
  capabilities = ["read"]
}
path "kvv2/data/services/paperless/admin" {
  capabilities = ["read"]
}
path "kvv2/data/services/paperless/redis" {
  capabilities = ["read"]
}
path "kvv2/data/services/paperless/ses/incoming" {
  capabilities = ["read"]
}
path "kvv2/data/services/paperless/smtp" {
  capabilities = ["read"]
}
path "identity/oidc/client/paperless" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "paperless-secret-key" {
  path = "kvv2/services/paperless/secret-key"

  data_json = jsonencode(
    {
      "key" : var.paperless_secret_key,
    }
  )
}

resource "vault_generic_secret" "paperless-admin" {
  path = "kvv2/services/paperless/admin"

  data_json = jsonencode(
    {
      "username" : var.paperless_admin_username,
      "password" : var.paperless_admin_password,
      "email" : var.paperless_admin_email,
    }
  )
}

resource "vault_generic_secret" "paperless-redis" {
  path = "kvv2/services/paperless/redis"

  data_json = jsonencode(
    {
      "password" : var.paperless_redis_password,
    }
  )
}

resource "vault_generic_secret" "paperless-ses-incoming" {
  path = "kvv2/services/paperless/ses/incoming"

  data_json = jsonencode(
    {
      "queue_url" : module.paperless_ses_incoming.queue_url,
      "bucket_name" : module.paperless_ses_incoming.bucket_name,
      "aws_access_key_id" : module.paperless_ses_incoming.user_access_key,
      "aws_secret_access_key" : module.paperless_ses_incoming.user_secret_key,
    }
  )
}

# TODO: this is currently not used by the app
resource "vault_generic_secret" "paperless-smtp" {
  path = "kvv2/services/paperless/smtp"

  data_json = jsonencode(
    {
      "username" : var.ses_smtp_username,
      "password" : var.ses_smtp_password,
      "host" : var.ses_smtp_host,
    }
  )
}
