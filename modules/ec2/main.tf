# Module: ec2 (stub)
# TODO: aws_instance, security group, key pair, user_data bootstrap.

variable "project" {
  type = string
}

variable "subnet_id" {
  type    = string
  default = null
}

# output "public_ip" { value = aws_instance.this.public_ip }
