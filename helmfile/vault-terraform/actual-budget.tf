module "actual-budget" {
  source             = "../lib/terraform/service"
  name               = "actual-budget"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  oidc = {
    redirect_uris = ["https://actual-budget.${var.domain}/openid/callback"]
    group_ids     = [vault_identity_group.this["actual-budget"].id]
  }
}
