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

resource "vault_identity_oidc_provider" "main" {
  name          = "main"
  https_enabled = true
  issuer_host   = "vault.${var.domain}"

  # Every client is allowed to use the provider. Authorization is not done here
  # but per client, by the assignment that names the groups permitted to log in
  # (see the `oidc` variable of the service module) - this list only ever said
  # "this client exists on purpose", and every client in this Vault is created by
  # this terraform or by the private repo's.
  #
  # It used to be an explicit list of client ids, which meant a forgotten entry
  # broke that service's login silently, and - the reason it is gone - that a
  # client created in another state (the private repo) could not be registered
  # without that state and this one depending on each other.
  allowed_client_ids = ["*"]
  scopes_supported = [
    vault_identity_oidc_scope.groups.name,
    vault_identity_oidc_scope.email.name,
    vault_identity_oidc_scope.profile.name,
  ]
}
