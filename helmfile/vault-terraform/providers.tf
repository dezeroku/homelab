terraform {
  required_version = "~> 1.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.19.0"
    }
    lldap = {
      source  = "tasansga/lldap"
      version = "~> 0.4.1"
    }
  }
}

provider "vault" {
  # Using $VAULT_ADDR from env as default
}

provider "lldap" {
  http_url = "https://lldap.${var.domain}"
  ldap_url = "ldaps://ldaps.lldap.${var.domain}:636"
  username = "admin"
  password = var.lldap_admin_password
  base_dn  = local.base_dn
}
