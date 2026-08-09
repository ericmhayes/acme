# Module: observability
# Datadog SLOs and monitors as code. Exactly three P1 paging monitors (reminder
# delivery failure, API availability SLO fast burn, RDS unavailable/connection
# saturation) routed to PagerDuty; a small set of non-paging monitors routed to
# Slack by severity. Two SLOs: booking API availability and reminder dispatch
# latency. Paging is gated by var.enable_paging so lower environments notify
# Slack only.

locals {
  # P1 monitors page in environments where paging is enabled; elsewhere they fall
  # back to the warning Slack channel so nothing wakes anyone in dev/staging.
  p1_target = var.enable_paging ? var.pagerduty_notification : var.slack_warning_channel
}

# --- SLOs ---

resource "datadog_service_level_objective" "api_availability" {
  name        = "${var.name_prefix} booking API availability"
  type        = "metric"
  description = "Successful booking API responses over total, target ${var.api_availability_slo_target}%."

  query {
    numerator   = "sum:acme.api.requests.success{env:${var.environment}}.as_count()"
    denominator = "sum:acme.api.requests.total{env:${var.environment}}.as_count()"
  }

  thresholds {
    timeframe = "30d"
    target    = var.api_availability_slo_target
    warning   = var.api_availability_slo_target + 0.05
  }

  tags = var.tags
}

resource "datadog_service_level_objective" "reminder_latency" {
  name        = "${var.name_prefix} reminder dispatch latency"
  type        = "metric"
  description = "Reminders dispatched within 15 minutes of target over total, target ${var.reminder_latency_slo_target}%."

  query {
    numerator   = "sum:acme.reminders.dispatched_within_target{env:${var.environment}}.as_count()"
    denominator = "sum:acme.reminders.dispatched{env:${var.environment}}.as_count()"
  }

  thresholds {
    timeframe = "30d"
    target    = var.reminder_latency_slo_target
    warning   = var.reminder_latency_slo_target + 0.5
  }

  tags = var.tags
}

# --- P1 paging monitors (exactly three) ---

resource "datadog_monitor" "reminder_delivery_failure" {
  name    = "[${var.environment}] Reminder delivery failures"
  type    = "metric alert"
  message = "Reminder deliveries are failing. ${local.p1_target}"

  query = "sum(last_10m):sum:acme.reminders.delivery.failed{env:${var.environment}}.as_count() > 10"

  monitor_thresholds {
    critical = 10
    warning  = 5
  }

  priority = 1
  tags     = var.tags
}

resource "datadog_monitor" "api_availability_fast_burn" {
  name    = "[${var.environment}] Booking API availability SLO fast burn"
  type    = "slo alert"
  message = "Booking API error budget burning fast. ${local.p1_target}"

  query = "burn_rate(\"${datadog_service_level_objective.api_availability.id}\").over(\"1h\").long_window(\"1h\").short_window(\"5m\") > 14.4"

  monitor_thresholds {
    critical = 14.4
  }

  priority = 1
  tags     = var.tags
}

resource "datadog_monitor" "rds_unavailable" {
  name    = "[${var.environment}] RDS unavailable or connections saturated"
  type    = "metric alert"
  message = "RDS is unreachable or approaching connection limits. ${local.p1_target}"

  query = "avg(last_5m):avg:aws.rds.database_connections{dbinstanceidentifier:${var.name_prefix}-postgres} > 80"

  monitor_thresholds {
    critical = 80
    warning  = 60
  }

  priority = 1
  tags     = var.tags
}

# --- Non-paging monitors (route to Slack by severity) ---

resource "datadog_monitor" "reminder_dlq_not_empty" {
  name    = "[${var.environment}] Reminder DLQ has messages"
  type    = "metric alert"
  message = "Messages have landed in the reminder dead-letter queue. ${var.slack_warning_channel}"

  query = "sum(last_5m):sum:aws.sqs.approximate_number_of_messages_visible{queuename:${var.name_prefix}-reminders-dlq} > 0"

  monitor_thresholds {
    critical = 0
  }

  priority = 3
  tags     = var.tags
}

resource "datadog_monitor" "ecs_cpu_high" {
  name    = "[${var.environment}] ECS service CPU sustained high"
  type    = "metric alert"
  message = "An ECS service has sustained high CPU. ${var.slack_warning_channel}"

  query = "avg(last_15m):avg:ecs.fargate.cpu.percent{env:${var.environment}} > 85"

  monitor_thresholds {
    critical = 85
    warning  = 70
  }

  priority = 3
  tags     = var.tags
}

resource "datadog_monitor" "rds_storage_low" {
  name    = "[${var.environment}] RDS free storage low"
  type    = "metric alert"
  message = "RDS free storage is running low. ${var.slack_info_channel}"

  query = "avg(last_30m):avg:aws.rds.free_storage_space{dbinstanceidentifier:${var.name_prefix}-postgres} < 5000000000"

  monitor_thresholds {
    critical = 5000000000
  }

  priority = 4
  tags     = var.tags
}
