output "access_key_id" {
  value = aws_iam_access_key.cert.id
}

output "access_key_secret" {
  value     = aws_iam_access_key.cert.secret
  sensitive = true
}
