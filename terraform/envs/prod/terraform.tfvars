aws_region     = "us-east-1"
aws_account_id = "210987654321"
name_prefix    = "acme-prod"
environment    = "prod"

tags = {
  Project     = "acme"
  Environment = "prod"
  ManagedBy   = "terraform"
  Owner       = "infra"
}

# Networking
vpc_cidr             = "10.30.0.0/16"
public_subnet_cidrs  = ["10.30.0.0/20", "10.30.16.0/20"]
private_subnet_cidrs = ["10.30.128.0/20", "10.30.144.0/20"]
nat_gateway_count    = 2

# Secrets
secret_recovery_window_days = 30

# Database
db_instance_class        = "db.t4g.medium"
db_allocated_storage     = 50
db_max_allocated_storage = 500
db_multi_az              = true
db_backup_retention_days = 30
db_deletion_protection   = true

# Services
api_desired_count    = 2
web_desired_count    = 2
worker_desired_count = 2

# Observability
datadog_enable_paging = true
