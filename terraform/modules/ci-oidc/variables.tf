variable "name_prefix" {
  description = "Prefix applied to role names, e.g. \"acme-dev\"."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
}

variable "github_org" {
  description = "GitHub organization or user that owns the repo."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
}

variable "create_oidc_provider" {
  description = "Whether to create the IAM OIDC provider. One per account, so true in the first env applied per account and false thereafter."
  type        = bool
  default     = true
}

variable "prod_environment_claim" {
  description = "GitHub environment name that gates the apply role via the OIDC \"environment:\" subject claim. Empty disables the environment condition (non-prod)."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
