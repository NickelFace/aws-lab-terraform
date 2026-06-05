variable "project" {
  description = "Project name for tagging and naming"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket the instance role may access"
  type        = string
}
