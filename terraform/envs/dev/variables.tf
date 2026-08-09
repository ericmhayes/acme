variable "aws_region" {
  description = "AWS region for this environment."
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID this environment deploys into."
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

# --- Networking ---

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets, one per AZ."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets, one per AZ."
  type        = list(string)
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways (1 non-prod, 2 prod)."
  type        = number
}

# --- Secrets ---

variable "secret_recovery_window_days" {
  description = "Recovery window before a deleted secret is purged."
  type        = number
  default     = 7
}

# --- Database ---

variable "db_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16.4"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB."
  type        = number
}

variable "db_max_allocated_storage" {
  description = "Storage autoscaling ceiling in GB."
  type        = number
}

variable "db_multi_az" {
  description = "Whether to run a Multi-AZ standby."
  type        = bool
}

variable "db_name" {
  description = "Name of the initial database."
  type        = string
  default     = "acme"
}

variable "db_master_username" {
  description = "Master username. Password is managed by RDS in Secrets Manager."
  type        = string
  default     = "acme_admin"
}

variable "db_backup_retention_days" {
  description = "Number of days to retain automated backups."
  type        = number
}

variable "db_deletion_protection" {
  description = "Whether deletion protection is enabled."
  type        = bool
}
