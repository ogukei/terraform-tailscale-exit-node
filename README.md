
## Usage

Specify your ssh public key filename in `terraform.tfvars`
```
touch terraform.tfvars
# edit terraform.tfvars
```

An example contents of terraform.tfvars
```
aws_public_key_filename = "/home/user/.ssh/id_ed25519.pub"
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

Ping it.
```
ping <public_ip>
```

SSH into your instance.
```
ssh ubuntu@<public_ip>
```
