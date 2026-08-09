variable "name_prefix" {
  description = "Prefix applied to resource names, e.g. \"acme-dev\"."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
}

variable "vpc_id" {
  description = "VPC the ALB is deployed into."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs the ALB is attached to."
  type        = list(string)
}

variable "domain_name" {
  description = "Primary domain for the ACM certificate (e.g. acme-example.com)."
  type        = string
}

variable "subject_alternative_names" {
  description = "Additional names on the ACM certificate (e.g. api./app. subdomains)."
  type        = list(string)
  default     = []
}

variable "enable_waf" {
  description = "Whether to associate a WAF WebACL with the ALB."
  type        = bool
  default     = true
}

variable "booking_rate_limit" {
  description = "Max requests per 5-minute window per IP to the booking path before WAF blocks (rate-based rule)."
  type        = number
  default     = 2000
}

variable "booking_path_prefix" {
  description = "URI path prefix the booking rate limit applies to (should match the app's booking route)."
  type        = string
  default     = "/api/bookings"
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
