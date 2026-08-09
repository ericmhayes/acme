variable "name_prefix" {
  description = "Prefix applied to repository names, e.g. \"acme\"."
  type        = string
}

variable "repository_names" {
  description = "Short names of the repositories to create (e.g. [\"api\", \"web\", \"worker\"])."
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "IMMUTABLE or MUTABLE tag policy."
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Whether to scan images on push."
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Maximum number of tagged images to retain per repository."
  type        = number
  default     = 20
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
