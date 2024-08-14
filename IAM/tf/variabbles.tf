# IAM/tf/variables.tf

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-west-2"
}

variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
}

