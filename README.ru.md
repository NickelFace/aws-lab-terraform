[🇬🇧 English version](README.md)

# aws-lab-terraform

![Terraform](https://img.shields.io/badge/Terraform-1.5+-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-VPC%20·%20EC2%20·%20S3%20·%20IAM-232F3E?logo=amazonaws&logoColor=white)

Инфраструктура как код для небольшой лабораторной среды AWS, развёртываемая через Terraform. Создано как практическая подготовка к экзамену **AWS Solutions Architect Associate** — каждая изученная лаб должна воспроизводиться кодом, а не кликами в консоли.

Один `terraform apply` поднимает VPC с публичной и приватной подсетями, EC2-хост с nginx, версионируемый зашифрованный S3-бакет и IAM-роль с минимальными правами, дающую инстансу доступ **только** к этому бакету.

## Планируемая архитектура

```
                 ┌─────────────────────────── VPC (10.20.0.0/16) ───────────────────────────┐
                 │                                                                           │
   Internet ──► IGW ──► Public subnet ──► EC2 (web)                                          │
                 │                          │  IAM instance profile (least-privilege → S3)   │
                 │                          ▼                                                │
                 │                        S3 bucket (versioned, encrypted, private)          │
                 └───────────────────────────────────────────────────────────────────────────┘
```

| Модуль | Создаёт |
|---|---|
| [`modules/vpc`](modules/vpc) | VPC, публичная/приватная подсеть, internet gateway, таблица маршрутов |
| [`modules/ec2`](modules/ec2) | EC2 инстанс (AL2023 + nginx), security group, bootstrap user_data |
| [`modules/s3`](modules/s3) | S3 бакет с версионированием, AES256-шифрованием, блокировкой публичного доступа |
| [`modules/iam`](modules/iam) | IAM роль + instance profile с доступом только к нужному бакету |

## Использование

```bash
cp terraform.tfvars.example terraform.tfvars   # укажи регион, проект, свой SSH CIDR
terraform init
terraform plan
terraform apply
```

После применения `terraform output instance_public_ip` покажет адрес nginx-хоста. Удалить всё: `terraform destroy`.

> Замечание: `allowed_ssh_cidr` по умолчанию `0.0.0.0/0` для удобства — ограничь до своего `/32` в `terraform.tfvars` перед реальным использованием.

## Структура

```
.
├── versions.tf      # ограничения версий Terraform и провайдера
├── providers.tf     # AWS провайдер + теги по умолчанию
├── variables.tf     # регион, проект, vpc_cidr
├── main.tf          # корневой модуль (вызовы модулей)
├── outputs.tf       # экспортируемые выходные данные
└── modules/
    ├── vpc/  ec2/  s3/  iam/
```

---

Часть [инфраструктурного портфолио](https://github.com/NickelFace?tab=repositories) · см. также [homelab-infrastructure](https://github.com/NickelFace/homelab-infrastructure)
