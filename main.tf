# Root module — wires the lab together: VPC -> S3 -> IAM -> EC2.

module "vpc" {
  source   = "./modules/vpc"
  project  = var.project
  vpc_cidr = var.vpc_cidr
}

module "s3" {
  source  = "./modules/s3"
  project = var.project
}

module "iam" {
  source        = "./modules/iam"
  project       = var.project
  s3_bucket_arn = module.s3.bucket_arn
}

module "ec2" {
  source                = "./modules/ec2"
  project               = var.project
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.public_subnet_id
  instance_type         = var.instance_type
  instance_profile_name = module.iam.instance_profile_name
  key_name              = var.key_name
  allowed_ssh_cidr      = var.allowed_ssh_cidr
}
