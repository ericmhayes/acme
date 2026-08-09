# Contract outputs for the ci-oidc module. Wired to real resources in Phase 4.

output "oidc_provider_arn" {
  description = "ARN of the GitHub Actions IAM OIDC provider."
  value       = null
}

output "plan_role_arn" {
  description = "ARN of the read-only Terraform plan role assumed on pull requests."
  value       = null
}

output "apply_role_arn" {
  description = "ARN of the Terraform apply role assumed on merge (gated in prod)."
  value       = null
}
