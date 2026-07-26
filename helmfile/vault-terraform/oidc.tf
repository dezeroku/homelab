resource "vault_identity_oidc_scope" "profile" {
  name = "profile"
  # Seems that this field really doesn't like jsonencode
  template = "{\"username\":{{identity.entity.name}},\"preferred_username\":{{identity.entity.name}}}"
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

locals {
  # SINGLE REGISTRATION POINT for OIDC clients allowed by the provider.
  # Every service that creates an OIDC client MUST be listed here or its login breaks.
  # (Sibling modules can't be reflected over, so this list is maintained by hand;
  # compact() drops any null client_ids from modules where oidc happens to be unset.)
  oidc_client_ids = compact([
    module.oauth2-proxy.oidc_client_id,
    vault_identity_oidc_client.argocd.client_id,
    vault_identity_oidc_client.argocd-cli.client_id,
    vault_identity_oidc_client.grafana.client_id,
    vault_identity_oidc_client.grafana_backup.client_id,
    module.paperless.oidc_client_id,
    module.ryot.oidc_client_id,
    module.hedgedoc.oidc_client_id,
    module.wikijs.oidc_client_id,
    module.immich.oidc_client_id,
    module.filebrowser-drive.oidc_client_id,
    module.actual-budget.oidc_client_id,
    module.esphome.oidc_client_id,
    module.change-detection.oidc_client_id,
    module.flatnotes.oidc_client_id,
    module.filebrowser-media.oidc_client_id,
    module.filebrowser-media-readonly.oidc_client_id,
    module.metube.oidc_client_id,
    module.redbot-main.oidc_client_id,
    module.redbot-premiers.oidc_client_id,
    module.navidrome.oidc_client_id,
    module.silverbullet.oidc_client_id,
  ])
}

resource "vault_identity_oidc_provider" "main" {
  name               = "main"
  https_enabled      = true
  issuer_host        = "vault.${var.domain}"
  allowed_client_ids = local.oidc_client_ids
  scopes_supported = [
    vault_identity_oidc_scope.groups.name,
    vault_identity_oidc_scope.email.name,
    vault_identity_oidc_scope.profile.name,
  ]
}
