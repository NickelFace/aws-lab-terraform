# aws-lab-terraform

![Terraform](https://img.shields.io/badge/Terraform-1.5+-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-VPC%20·%20EC2%20·%20S3%20·%20IAM-232F3E?logo=amazonaws&logoColor=white)
![Status](https://img.shields.io/badge/status-scaffold%20(WIP)-yellow)

Infrastructure-as-Code for a small AWS lab environment, provisioned with Terraform. Built as hands-on preparation for the **AWS Solutions Architect Associate** exam — the goal is that every lab I study ends up reproducible in code, not clicked together in the console.

> **Status: scaffold.** Module structure, provider pinning, and variables are in place. The resource definitions inside each module are stubbed with `TODO`s and will be filled in incrementally.

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

| Module | Will provision |
|---|---|
| [`modules/vpc`](modules/vpc) | VPC, public/private subnets, internet gateway, route tables |
| [`modules/ec2`](modules/ec2) | EC2 instance, security group, key pair, bootstrap user_data |
| [`modules/s3`](modules/s3) | S3 bucket with versioning, encryption, public-access block |
| [`modules/iam`](modules/iam) | IAM role + instance profile granting EC2 scoped S3 access |

## Usage (once implemented)

```bash
cp terraform.tfvars.example terraform.tfvars   # adjust region / project
terraform init
terraform plan
terraform apply
```

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
