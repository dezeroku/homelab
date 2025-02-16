resource "vault_identity_oidc_scope" "profile" {
  name = "profile"
  # Seems that this field really doesn't like jsonencode
  template = "{\"username\":{{identity.entity.name}}}"
}

resource "vault_identity_oidc_scope" "email" {
  name = "email"
  # Seems that this field really doesn't like jsonencode
  template = "{\"email\":{{identity.entity.metadata.email}}}"
}

resource "vault_policy" "oidc_auth" {
  name = "oidc-auth"

  policy = <<EOT
path "identity/oidc/provider/${vault_identity_oidc_provider.main.name}/authorize" {
  capabilities = [ "read" ]
}
EOT
}

resource "vault_identity_oidc_scope" "groups" {
  name = "groups"
  # Seems that this field really doesn't like jsonencode
  template = "{\"groups\":{{identity.entity.groups.names}}}"
}

resource "vault_identity_oidc_provider" "main" {
  name          = "main"
  https_enabled = true
  issuer_host   = "vault.${var.domain}"
  allowed_client_ids = [
    vault_identity_oidc_client.oauth2-proxy.client_id,
    vault_identity_oidc_client.argocd.client_id,
    vault_identity_oidc_client.argocd-cli.client_id,
    vault_identity_oidc_client.grafana.client_id,
    vault_identity_oidc_client.grafana_backup.client_id,
    vault_identity_oidc_client.paperless.client_id,
    vault_identity_oidc_client.ryot.client_id,
    vault_identity_oidc_client.wikijs.client_id,
    vault_identity_oidc_client.immich.client_id,
  ]
  scopes_supported = [
    vault_identity_oidc_scope.groups.name,
    vault_identity_oidc_scope.email.name,
    vault_identity_oidc_scope.profile.name,
  ]
}
