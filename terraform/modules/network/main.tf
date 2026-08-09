# Module: network
# Responsibility: A VPC spanning two AZs with public and private subnets, an
#   internet gateway, NAT gateway(s) (count driven by var.nat_gateway_count so
#   non-prod runs one and prod runs two), route tables, VPC flow logs, and the
#   interface/gateway VPC endpoints that let private-subnet Fargate tasks reach
#   ECR, CloudWatch Logs, Secrets Manager, and S3 without a public path.
#
# Implemented in Phase 2. This file is an intentional stub defining the module
# boundary only.
