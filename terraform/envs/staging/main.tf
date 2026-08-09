# Root module: staging (non-prod account)
#
# Composes the shared modules for the staging environment. Staging shares the
# non-prod account with dev but is isolated by VPC and IAM. Backend and provider
# are defined here; compute and delivery modules are added in later phases.

terraform {
  backend "s3" {
    bucket         = "acme-example-tfstate-nonprod"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "acme-example-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = var.tags
  }
}

locals {
  availability_zones = [for suffix in ["a", "b"] : "${var.aws_region}${suffix}"]
}

module "network" {
  source = "../../modules/network"

  name_prefix          = var.name_prefix
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = local.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  nat_gateway_count    = var.nat_gateway_count
  tags                 = var.tags
}

module "ecr" {
  source = "../../modules/ecr"

  name_prefix      = var.name_prefix
  repository_names = ["api", "web", "worker"]
  tags             = var.tags
}

module "secrets" {
  source = "../../modules/secrets"

  name_prefix          = var.name_prefix
  environment          = var.environment
  recovery_window_days = var.secret_recovery_window_days
  tags                 = var.tags
}

module "database" {
  source = "../../modules/database"

  name_prefix           = var.name_prefix
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  engine_version        = var.db_engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  multi_az              = var.db_multi_az
  db_name               = var.db_name
  master_username       = var.db_master_username
  backup_retention_days = var.db_backup_retention_days
  deletion_protection   = var.db_deletion_protection
  tags                  = var.tags
}
