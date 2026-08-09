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

# --- Compute / services ---

variable "domain_name" {
  description = "Base domain for the ALB certificate and host routing."
  type        = string
  default     = "acme-example.com"
}

variable "enable_waf" {
  description = "Whether to associate a WAF WebACL with the ALB."
  type        = bool
  default     = true
}

variable "task_cpu" {
  description = "Fargate task CPU units for the services."
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Fargate task memory (MiB) for the services."
  type        = number
  default     = 1024
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days for the services."
  type        = number
  default     = 90
}

variable "api_desired_count" {
  description = "Number of API task replicas."
  type        = number
}

variable "web_desired_count" {
  description = "Number of web task replicas."
  type        = number
}

variable "worker_desired_count" {
  description = "Number of worker task replicas."
  type        = number
}

variable "reminder_sweep_expression" {
  description = "EventBridge Scheduler expression driving the reminder sweep."
  type        = string
  default     = "rate(1 minute)"
}

# --- Observability (Datadog) ---

variable "datadog_pagerduty_notification" {
  description = "Datadog notification handle for P1 paging monitors."
  type        = string
  default     = "@pagerduty-Acme-P1"
}

variable "datadog_slack_warning" {
  description = "Datadog Slack handle for P2/warning monitors."
  type        = string
  default     = "@slack-acme-alerts"
}

variable "datadog_slack_info" {
  description = "Datadog Slack handle for P3/info monitors."
  type        = string
  default     = "@slack-acme-notifications"
}

variable "api_availability_slo_target" {
  description = "Booking API availability SLO target percentage."
  type        = number
  default     = 99.9
}

variable "reminder_latency_slo_target" {
  description = "Reminder dispatch latency SLO target percentage."
  type        = number
  default     = 99
}

variable "datadog_enable_paging" {
  description = "Whether P1 monitors page (prod) or route to Slack only (non-prod)."
  type        = bool
}
