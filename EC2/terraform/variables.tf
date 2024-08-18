variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "AWS Region"
  default     = "us-west-2"
}

variable "az" {
  description = "Availability Zone"
  default     = "us-west-2a"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}
