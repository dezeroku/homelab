output "access_key_id" {
  value = aws_iam_access_key.ses.id
}

output "access_key_secret" {
  value     = aws_iam_access_key.ses.secret
  sensitive = true
}
