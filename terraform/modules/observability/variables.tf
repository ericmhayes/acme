variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to monitor/SLO names, e.g. \"acme-prod\"."
  type        = string
}

variable "pagerduty_notification" {
  description = "Datadog notification handle for P1 paging monitors, e.g. \"@pagerduty-Acme-P1\"."
  type        = string
}

variable "slack_warning_channel" {
  description = "Datadog Slack handle for P2/warning monitors, e.g. \"@slack-acme-alerts\"."
  type        = string
}

variable "slack_info_channel" {
  description = "Datadog Slack handle for P3/info monitors, e.g. \"@slack-acme-notifications\"."
  type        = string
}

variable "api_availability_slo_target" {
  description = "Target for the booking API availability SLO (e.g. 99.9)."
  type        = number
  default     = 99.9
}

variable "reminder_latency_slo_target" {
  description = "Target for the reminder dispatch latency SLO (e.g. 99)."
  type        = number
  default     = 99
}

variable "enable_paging" {
  description = "Whether P1 monitors actually page. False in non-prod so lower envs route to Slack only."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Datadog tags applied to monitors and SLOs."
  type        = list(string)
  default     = []
}
