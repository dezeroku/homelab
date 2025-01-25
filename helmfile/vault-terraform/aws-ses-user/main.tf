terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_iam_user" "ses" {
  name = var.username
}

resource "aws_iam_access_key" "ses" {
  user = aws_iam_user.ses.name
}

resource "aws_iam_user_policy" "ses_po" {
  user = aws_iam_user.ses.name

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ses:SendEmail",
            "ses:SendRawEmail",
          ],
          "Resource" : "*",
          "Condition" : {
            "ForAllValues:StringLike" : {
              "ses:FromAddress" : [
                "homeserver-*@*",
                "*@${var.domain}"
              ]
            }
          }
        },
      ]
    }
  )
}
