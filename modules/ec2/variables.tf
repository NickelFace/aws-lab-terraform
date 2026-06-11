variable "project" {
  description = "Project name for tagging and naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC the instance and security group live in"
  type        = string
}

variable "subnet_id" {
  description = "Subnet to launch the instance in"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_profile_name" {
  description = "IAM instance profile to attach"
  type        = string
}

variable "key_name" {
  description = "Optional existing EC2 key pair name for SSH"
  type        = string
  default     = null
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to reach the instance over SSH — use your /32"
  type        = string
}

variable "allowed_http_cidr" {
  description = "CIDR allowed to reach the instance over HTTP — default your /32 or a load balancer CIDR"
  type        = string
  default     = "0.0.0.0/0"
}
