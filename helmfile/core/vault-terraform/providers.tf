terraform {
  required_version = "~> 1.6.4"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.19.0"
    }
  }
}

provider "vault" {
  # Using $VAULT_ADDR from env as default
}
