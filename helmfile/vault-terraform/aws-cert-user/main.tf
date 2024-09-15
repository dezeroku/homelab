terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "cert" {
  name = var.username
}

resource "aws_iam_access_key" "cert" {
  user = aws_iam_user.cert.name
}

resource "aws_iam_user_policy" "cert_po" {
  user = aws_iam_user.cert.name

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "route53:GetChange",
          "Resource" : "arn:aws:route53:::change/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets"
          ],
          "Resource" : "arn:aws:route53:::hostedzone/${var.hosted_zone_id}"
        },
        {
          "Effect" : "Allow",
          "Action" : "route53:ListHostedZonesByName",
          "Resource" : "*"
        }
      ]
    }
  )
}
