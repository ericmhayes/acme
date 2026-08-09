# Contract outputs for the observability module. Wired to real resources in Phase 3.

output "monitor_ids" {
  description = "Map of logical monitor name to its Datadog monitor ID."
  value       = null
}

output "slo_ids" {
  description = "Map of logical SLO name to its Datadog SLO ID."
  value       = null
}
