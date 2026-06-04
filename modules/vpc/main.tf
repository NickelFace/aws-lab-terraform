# Module: vpc (stub)
# TODO: aws_vpc, public/private subnets, internet gateway, route tables, NAT.

variable "project" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

# output "vpc_id"          { value = aws_vpc.this.id }
# output "public_subnet_id" { value = aws_subnet.public.id }
