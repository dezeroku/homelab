resource "vault_kubernetes_auth_backend_role" "tgtg" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "tgtg"
  bound_service_account_namespaces = ["tgtg"]
  token_ttl                        = 3600
  bound_service_account_names      = ["default"]
  token_policies                   = ["tgtg"]
}

resource "vault_policy" "tgtg" {
  name = "tgtg"

  policy = <<EOT
path "kvv2/data/services/tgtg/username" {
  capabilities = ["read"]
}
path "kvv2/data/services/tgtg/ses" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "tgtg-username" {
  path = "kvv2/services/tgtg/username"

  data_json = jsonencode(
    {
      "username" : var.tgtg_username
    }
  )
}

resource "vault_generic_secret" "tgtg-ses" {
  path = "kvv2/services/tgtg/ses"

  data_json = jsonencode(
    {
      "access_key_id" : var.ses_access_key_id,
      "access_key_secret" : var.ses_access_key_secret,
      "from" : var.tgtg_ses_from,
      "to" : var.tgtg_ses_to
    }
  )
}
