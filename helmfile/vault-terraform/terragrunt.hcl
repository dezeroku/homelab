dependency "cert_user" {
  config_path = "./aws-cert-user"
}

dependency "ses_user" {
  config_path = "./aws-ses-user"
}


inputs = {
  cert_manager_aws_access_key_id     = dependency.cert_user.outputs.access_key_id
  cert_manager_aws_secret_access_key = dependency.cert_user.outputs.access_key_secret
  ses_access_key_id                  = dependency.ses_user.outputs.access_key_id
  ses_access_key_secret              = dependency.ses_user.outputs.access_key_secret
}
