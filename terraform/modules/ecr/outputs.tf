# Contract outputs for the ecr module. Wired to real resources in Phase 2.

output "repository_urls" {
  description = "Map of short repository name to its ECR repository URL."
  value       = null
}

output "repository_arns" {
  description = "Map of short repository name to its ECR repository ARN."
  value       = null
}
