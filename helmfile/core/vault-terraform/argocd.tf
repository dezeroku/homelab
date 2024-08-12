resource "vault_identity_oidc_assignment" "argocd" {
  name      = "argocd"
  group_ids = [vault_identity_group.users.id]
}

resource "vault_policy" "argocd" {
  name = "argocd"

  policy = <<EOT
path "identity/oidc/client/argocd" {
  capabilities = ["read"]
}
path "kvv2/data/core/argocd/credentials/*" {
  capabilities = ["read"]
}
EOT
}

resource "vault_identity_oidc_client" "argocd" {
  name = "argocd"
  redirect_uris = [
    "https://argocd.${var.domain}/auth/callback",
  ]
  assignments      = [vault_identity_oidc_assignment.argocd.name]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

resource "vault_kubernetes_auth_backend_role" "argocd" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "argocd"
  bound_service_account_namespaces = ["argocd"]
  token_ttl                        = 3600
  bound_service_account_names      = ["argocd-server"]
  token_policies                   = ["argocd"]
}

resource "vault_generic_secret" "argocd-credentials-homelab" {
  path = "kvv2/core/argocd/credentials/homelab"

  data_json = jsonencode(
    {
      "type" : "git",
      "url" : "git@github.com:dezeroku/homelab.git"
      "sshPrivateKey" : var.argocd_credentials_homelab_private_key
    }
  )
}
