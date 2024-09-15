output "access_key_id" {
  value = aws_iam_access_key.ses.id
}

output "access_key_secret" {
  value     = aws_iam_access_key.ses.secret
  sensitive = true
}

output "smtp_username" {
  value     = aws_iam_user.ses.name
  sensitive = true
}

output "smtp_password" {
  value     = aws_iam_access_key.ses.ses_smtp_password_v4
  sensitive = true
}

output "smtp_host" {
  value = var.smtp_host
}
