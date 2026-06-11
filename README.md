# aws-lab-terraform

[![CI](https://github.com/NickelFace/aws-lab-terraform/actions/workflows/ci.yml/badge.svg)](https://github.com/NickelFace/aws-lab-terraform/actions/workflows/ci.yml)
![Terraform](https://img.shields.io/badge/Terraform-1.5+-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-VPC%20·%20EC2%20·%20S3%20·%20IAM-232F3E?logo=amazonaws&logoColor=white)

Infrastructure-as-Code for a small AWS lab environment, provisioned with Terraform. Built as hands-on preparation for the **AWS Solutions Architect Associate** exam — the goal is that every lab I study ends up reproducible in code, not clicked together in the console.

A single `terraform apply` brings up a VPC with public/private subnets, an EC2 web host bootstrapped with nginx, a versioned and encrypted S3 bucket, and a least-privilege IAM role that lets the instance reach **only** that bucket.

## Planned architecture

```
                 ┌─────────────────────────── VPC (10.20.0.0/16) ───────────────────────────┐
                 │                                                                           │
   Internet ──► IGW ──► Public subnet ──► EC2 (web)                                          │
                 │                          │  IAM instance profile (least-privilege → S3)   │
                 │                          ▼                                                │
                 │                        S3 bucket (versioned, encrypted, private)          │
                 └───────────────────────────────────────────────────────────────────────────┘
```

| Module | Provisions |
|---|---|
| [`modules/vpc`](modules/vpc) | VPC, public/private subnets, internet gateway, route table, flow logs, default SG lockdown |
| [`modules/ec2`](modules/ec2) | EC2 instance (AL2023 + nginx), security group, bootstrap user_data |
| [`modules/s3`](modules/s3) | S3 bucket with versioning, KMS encryption, access logging, lifecycle, SNS notifications, cross-region replication |
| [`modules/iam`](modules/iam) | IAM role + instance profile granting EC2 scoped access to the bucket only |

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # set region, project, your SSH CIDR /32

# Optional: configure remote state (S3 backend + DynamoDB lock)
cp backend.tf.example backend.tf              # fill in your bucket/table names
# backend.tf is gitignored — never commit it

terraform init
terraform plan
terraform apply
```

After apply, `terraform output instance_public_ip` gives you the nginx host. Tear it all down with `terraform destroy`.

> `allowed_ssh_cidr` and `allowed_http_cidr` have no defaults — you must supply your own `/32` in `terraform.tfvars` (see `terraform.tfvars.example`).

## Layout

```
.
├── versions.tf      # Terraform + provider version constraints
├── providers.tf     # AWS provider + default tags
├── variables.tf     # region, project, vpc_cidr
├── main.tf          # root module wiring (module calls)
├── outputs.tf       # exposed outputs
└── modules/
    ├── vpc/  ec2/  s3/  iam/
```

---

Part of my [infrastructure & DevOps portfolio](https://github.com/NickelFace?tab=repositories) · see also [homelab-infrastructure](https://github.com/NickelFace/homelab-infrastructure).
