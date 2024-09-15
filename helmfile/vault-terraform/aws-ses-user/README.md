# aws-ses-user

This small terraform helper is responsible for creating an IAM user with proper permissions to be used with SES.

## Configuration

Run `terragrunt init` and `terragrunt apply` to create user and access key.

To obtain the access key id:

```
terraform output -raw access_key_id
```

Finally, to obtain the access key secret for further use, you can run:

```
terraform output -raw access_key_secret
```
