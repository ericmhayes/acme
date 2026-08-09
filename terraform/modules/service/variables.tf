variable "name_prefix" {
  description = "Prefix applied to resource names, e.g. \"acme-dev\"."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
}

variable "service_name" {
  description = "Short service name (e.g. \"api\" or \"web\")."
  type        = string
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster to run in."
  type        = string
}

variable "vpc_id" {
  description = "VPC the service runs in."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets the tasks run in."
  type        = list(string)
}

variable "image" {
  description = "Fully-qualified container image reference (ECR URL plus tag)."
  type        = string
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
}

variable "desired_count" {
  description = "Number of task replicas. Fixed; no autoscaling."
  type        = number
}

variable "cpu" {
  description = "Task CPU units (e.g. 256, 512)."
  type        = number
}

variable "memory" {
  description = "Task memory in MiB."
  type        = number
}

variable "https_listener_arn" {
  description = "ARN of the shared ALB HTTPS listener to attach the host rule to."
  type        = string
}

variable "alb_security_group_id" {
  description = "ALB security group; the service allows ingress only from it."
  type        = string
}

variable "host_header" {
  description = "Host header this service answers to (e.g. api.acme-example.com)."
  type        = string
}

variable "database_security_group_id" {
  description = "Database security group to open Postgres ingress to. Empty for services that don't reach the DB directly (e.g. the web app)."
  type        = string
  default     = ""
}

variable "listener_rule_priority" {
  description = "Priority for this service's listener rule (unique per ALB)."
  type        = number
}

variable "health_check_path" {
  description = "Path the target group health check probes."
  type        = string
  default     = "/health"
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
  description = "Scale the service to zero outside working hours on a schedule (used in dev for cost). This is scheduled, not load-reactive, scaling."
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
