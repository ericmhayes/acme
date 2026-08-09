aws_region     = "us-east-1"
aws_account_id = "123456789012"
name_prefix    = "acme-staging"
environment    = "staging"

tags = {
  Project     = "acme"
  Environment = "staging"
  ManagedBy   = "terraform"
  Owner       = "infra"
}

# Networking
vpc_cidr             = "10.20.0.0/16"
public_subnet_cidrs  = ["10.20.0.0/20", "10.20.16.0/20"]
private_subnet_cidrs = ["10.20.128.0/20", "10.20.144.0/20"]
nat_gateway_count    = 1

# Secrets
secret_recovery_window_days = 7

# Database
db_instance_class        = "db.t4g.small"
db_allocated_storage     = 20
db_max_allocated_storage = 100
db_multi_az              = false
db_backup_retention_days = 7
db_deletion_protection   = false
