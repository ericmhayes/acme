# Contract outputs for the network module. Values are wired to real resources
# in Phase 2; declared here so downstream modules can rely on stable names.

output "vpc_id" {
  description = "ID of the VPC."
  value       = null
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = null
}

output "public_subnet_ids" {
  description = "IDs of the public subnets (one per AZ)."
  value       = null
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (one per AZ)."
  value       = null
}

output "vpc_endpoints_security_group_id" {
  description = "Security group attached to the interface VPC endpoints."
  value       = null
}
