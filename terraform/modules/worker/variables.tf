variable "name_prefix" {
  description = "Prefix applied to resource names, e.g. \"acme-dev\"."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster to run in."
  type        = string
}

variable "vpc_id" {
  description = "VPC the worker runs in."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets the tasks run in."
  type        = list(string)
}

variable "database_security_group_id" {
  description = "Database security group to open Postgres ingress to."
  type        = string
  default     = ""
}

variable "image" {
  description = "Fully-qualified worker container image reference (ECR URL plus tag)."
  type        = string
}

variable "desired_count" {
  description = "Number of worker task replicas. Fixed; no autoscaling."
  type        = number
  default     = 1
}

variable "cpu" {
  description = "Task CPU units."
  type        = number
}

variable "memory" {
  description = "Task memory in MiB."
  type        = number
}

variable "sweep_schedule_expression" {
  description = "EventBridge Scheduler expression driving the sweep, e.g. rate(1 minute)."
  type        = string
  default     = "rate(1 minute)"
}

variable "dlq_max_receive_count" {
  description = "Times a message is retried before moving to the dead-letter queue."
  type        = number
  default     = 5
}

variable "secret_arns" {
  description = "Map of container env var name to Secrets Manager ARN to inject."
  type        = map(string)
  default     = {}
}

variable "environment_variables" {
  description = "Non-secret environment variables for the container."
  type        = map(string)
  default     = {}
}

variable "datadog_api_key_secret_arn" {
  description = "Secrets Manager ARN of the Datadog API key for the agent sidecar."
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 90
}

variable "enable_scheduled_scaling" {
  description = "Scale the worker to zero outside working hours on a schedule (used in dev for cost). This is scheduled, not load-reactive, scaling."
  type        = bool
  default     = false
}

variable "scale_up_cron" {
  description = "Cron for scaling up to desired_count (in scale_timezone)."
  type        = string
  default     = "cron(0 8 ? * MON-FRI *)"
}

variable "scale_down_cron" {
  description = "Cron for scaling down to zero (in scale_timezone)."
  type        = string
  default     = "cron(0 19 ? * MON-FRI *)"
}

variable "scale_timezone" {
  description = "IANA timezone for the scaling schedules."
  type        = string
  default     = "America/New_York"
}

variable "tags" {
  description = "Tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}
