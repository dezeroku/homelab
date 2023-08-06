## Initialization
On the first run the unseal keys have to be generated and written down in a safe place, as subsequent restarts will require unsealing the vault with them.

```
# Only once on the initial deploy
kubectl exec -n vault -ti vault-0 -- vault operator init
```

Now you can follow the below instructions for unsealing the vault.

## Unsealing
Unsealing is required to unlock vault's content and it must be performed when pod restarts for whatever reason (pod killed, node restarted, etc.).
```
kubectl exec -n vault -ti vault-0 -- vault operator unseal # ... Unseal Key 1
kubectl exec -n vault -ti vault-0 -- vault operator unseal # ... Unseal Key 2
kubectl exec -n vault -ti vault-0 -- vault operator unseal # ... Unseal Key 3
```

## Accessing vault with CLI
On your local machine, get the `vault` executable and:
```
# Provide URL to vault (preferably add this as part of .bashrc or the equivalent for your shell)
export VAULT_ADDR=vault.<DOMAIN>

# You can use the "root" token obtained during the initialization in this step
vault login
```

## Setup
The vault content is controlled via Terraform files defined in `vault-terraform` directory.
The following steps assume that you have CLI access to the vault and `VAULT_ADDR` env variable exposed pointing to the vault instance.

The secret values are kept in `terraform.tfvars` file which is explicitly ignored by the version control.
To start, create your own copy of that file, based on the example one and modify the values:
```
cp terraform.tfvars.example terraform.tfvars
# modify values with an editor...
```

Run:
```
terraform init # only needed during the first run in the directory

terraform apply # to sync the configuration
```

All of the further changes should be reflected in the terraform.


## Revoke the root key
While the root token is very handy, it's also a security risk.
Just imagine this falling into the wrong hands!

It's recommended to revoke the root key when it's no longer needed (after the initial setup), it can be done with the following command (the root token can revoke itself):
```
vault token revoke <token>
```

If needed, the root token can be generated again with the following command (note that it requires access to the unseal keys)
```
# Start the process and note down the "OTP" value
kubectl exec -n vault -ti vault-0 -- vault operator generate-root -init

kubectl exec -n vault -ti vault-0 -- vault operator generate-root
# Provide first key
kubectl exec -n vault -ti vault-0 -- vault operator generate-root
# Provide second key
kubectl exec -n vault -ti vault-0 -- vault operator generate-root
# Provide third key and note down the "Encoded Token" value

# Finally decode the obtained root token with otp obtained in the first step
kubectl exec -n vault -ti vault-0 -- vault operator generate-root -decode <Encoded Token> -otp <OTP>
```
