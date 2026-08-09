variable "name_prefix" {
  description = "Prefix applied to secret names, e.g. \"acme-dev\"."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
}

variable "recovery_window_days" {
  description = "Days before a deleted secret is permanently removed. 0 in non-prod for easy cleanup, longer in prod."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
