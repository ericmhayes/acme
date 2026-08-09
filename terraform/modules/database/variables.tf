variable "name_prefix" {
  description = "Prefix applied to resource names, e.g. \"acme-dev\"."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
}

variable "vpc_id" {
  description = "VPC the database is deployed into."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "ingress_security_group_ids" {
  description = "Security groups allowed to connect to Postgres (the app tasks)."
  type        = list(string)
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "instance_class" {
  description = "RDS instance class. t4g.small non-prod, t4g.medium prod."
  type        = string
}

variable "allocated_storage" {
  description = "Initial allocated storage in GB."
  type        = number
}

variable "max_allocated_storage" {
  description = "Storage autoscaling ceiling in GB."
  type        = number
}

variable "multi_az" {
  description = "Whether to run a Multi-AZ standby. True in prod."
  type        = bool
}

variable "db_name" {
  description = "Name of the initial database."
  type        = string
}

variable "master_username" {
  description = "Master username. Password is managed by RDS in Secrets Manager."
  type        = string
}

variable "backup_retention_days" {
  description = "Number of days to retain automated backups."
  type        = number
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled. True in prod."
  type        = bool
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
