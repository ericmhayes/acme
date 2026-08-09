output "monitor_ids" {
  description = "Map of logical monitor name to its Datadog monitor ID."
  value = {
    reminder_delivery_failure  = datadog_monitor.reminder_delivery_failure.id
    api_availability_fast_burn = datadog_monitor.api_availability_fast_burn.id
    rds_unavailable            = datadog_monitor.rds_unavailable.id
    reminder_dlq_not_empty     = datadog_monitor.reminder_dlq_not_empty.id
    ecs_cpu_high               = datadog_monitor.ecs_cpu_high.id
    rds_storage_low            = datadog_monitor.rds_storage_low.id
  }
}

output "slo_ids" {
  description = "Map of logical SLO name to its Datadog SLO ID."
  value = {
    api_availability = datadog_service_level_objective.api_availability.id
    reminder_latency = datadog_service_level_objective.reminder_latency.id
  }
}
