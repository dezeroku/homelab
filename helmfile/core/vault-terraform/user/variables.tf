variable "username" {
  type = string
}

variable "user_password" {
  type = string
}

variable "metadata" {
  type = map(string)
}

variable "userpass_accessor" {
  type = string
}

variable "groups" {
  type = list(string)
}

variable "groups_mapping" {
  type = map(string)
}
