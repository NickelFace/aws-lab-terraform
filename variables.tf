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
