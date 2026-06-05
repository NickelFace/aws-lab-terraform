output "vpc_id" {
  description = "ID of the lab VPC"
  value       = module.vpc.vpc_id
}

output "instance_public_ip" {
  description = "Public IP of the lab EC2 instance"
  value       = module.ec2.public_ip
}

output "s3_bucket_name" {
  description = "Name of the lab S3 bucket"
  value       = module.s3.bucket_name
}
