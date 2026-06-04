# Root module — wires the lab together.
# STATUS: scaffold. Modules below are stubs; uncomment and implement incrementally.

# module "vpc" {
#   source   = "./modules/vpc"
#   project  = var.project
#   vpc_cidr = var.vpc_cidr
# }

# module "ec2" {
#   source     = "./modules/ec2"
#   project    = var.project
#   subnet_id  = module.vpc.public_subnet_id
# }

# module "s3" {
#   source  = "./modules/s3"
#   project = var.project
# }

# module "iam" {
#   source  = "./modules/iam"
#   project = var.project
# }
