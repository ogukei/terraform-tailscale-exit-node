# Terraform Tailscale Exit Node
Just `terraform apply` to spawn a Tailscale exit node on EC2 spot instance.

## Usage

Specify your ssh public key filename and the Tailscale Auth Key in `terraform.tfvars`.
```
touch terraform.tfvars
# edit terraform.tfvars
```

Generate an auth key from your Admin console https://login.tailscale.com/admin/settings/keys

An example contents of terraform.tfvars
```
aws_public_key_filename = "/home/user/.ssh/id_ed25519.pub"
tailscale_authkey = "tskey-auth-kD6nkqZR6911CNTRL-qku1R68kqZ191jwCZjExample"
```

AWS credentials
```
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=us-west-2
```

Run terraform
```
terraform init
terraform apply
```

After completions, a public_ip output variable will appear.
```
Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:

public_ip = "x.x.x.x"
```

Make sure that you can ping it.
```
ping <public_ip>
```

Also make sure that you can SSH into your instance.
```
ssh root@<public_ip>
```

Open https://login.tailscale.com/admin/machines then find the instance. In Routing Settings, allow Exit Node.

Install Tailscale client and specify to use the exit node in your tailnet.

Make sure you have now access to the internet via Tailscale VPN with exit node.

Please don't forget to destroy the instance after use.
```
terraform destroy
```

### Note
The instance type `c6gn.medium` is recommended since it provides better baseline network bandwidth.

See also https://fck-nat.dev/stable/choosing_an_instance_size/
