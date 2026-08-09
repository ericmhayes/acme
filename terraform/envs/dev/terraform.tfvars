aws_region     = "us-east-1"
aws_account_id = "123456789012"
name_prefix    = "acme-dev"
environment    = "dev"

tags = {
  Project     = "acme"
  Environment = "dev"
  ManagedBy   = "terraform"
  Owner       = "infra"
}
