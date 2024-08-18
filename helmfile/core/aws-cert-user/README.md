# aws-cert-user

This small terraform helper is responsible for creating an IAM user with proper permissions to be used with ACME.
With this in place, you can obtain a certificate from Let's Encrypt for your ingresses.

## Configuration

It's assumed that you already have a hosted zone set up in Route53.

At the very least you'll need to configure terraform to add permissions for the exact hosted zone, e.g. create a `terraform.tfvars` file with following content

```
hosted_zone_id = "your hosted zone id"
```

Then run `terraform init` and `terraform apply` to create user and access key.

To obtain the access key id:

```
terraform output -raw access_key_id
```

Finally, to obtain the access key secret for further use, you can run:

```
terraform output -raw access_key_secret
```
