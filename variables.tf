variable "aws_region" {
  description = "AWS region to deploy the lab into"
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Project name used for tagging and resource naming"
  type        = string
  default     = "aws-lab"
}

variable "vpc_cidr" {
  description = "CIDR block for the lab VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type for the lab web host"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to reach the instance over SSH — set to your IP (e.g. 203.0.113.1/32)"
  type        = string
}

variable "key_name" {
  description = "Optional name of an existing EC2 key pair for SSH access"
  type        = string
  default     = null
}
