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
