variable "aws_region" {
  description = "AWS region for this environment."
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID this environment deploys into (prod account)."
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to resource names in this environment."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "tags" {
  description = "Default tags applied to every resource via the provider."
  type        = map(string)
}
