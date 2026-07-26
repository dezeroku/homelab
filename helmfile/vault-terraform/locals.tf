locals {
  base_dn = join(",", [for part in split(".", var.domain) : "dc=${part}"])
}
