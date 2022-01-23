## How to




Reference:
* https://github.com/akuio/terraform-vpc-demo

```bash
terraform init
terraform plan -var-file=../../environments/staging/network/terraform.tfvars -lock=false
terraform apply --auto-approve -var-file=../../environments/dev/network/terraform.tfvars
```