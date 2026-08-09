# Root module: prod (dedicated prod account)
#
# Composes the shared modules for the production environment. Prod is a separate
# AWS account from dev/staging. Backend and provider are defined here; compute
# and delivery modules are added in later phases.

terraform {
  backend "s3" {
    bucket         = "acme-example-tfstate-prod"
    key            = "prod/terraform.tfstate"
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

provider "datadog" {}

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  name_prefix = var.name_prefix
  environment = var.environment
  tags        = var.tags
}

module "alb" {
  source = "../../modules/alb"

  name_prefix               = var.name_prefix
  environment               = var.environment
  vpc_id                    = module.network.vpc_id
  public_subnet_ids         = module.network.public_subnet_ids
  domain_name               = var.domain_name
  subject_alternative_names = ["api.${var.domain_name}", "app.${var.domain_name}"]
  enable_waf                = var.enable_waf
  tags                      = var.tags
}

module "api" {
  source = "../../modules/service"

  name_prefix                = var.name_prefix
  environment                = var.environment
  service_name               = "api"
  cluster_arn                = module.ecs_cluster.cluster_arn
  vpc_id                     = module.network.vpc_id
  private_subnet_ids         = module.network.private_subnet_ids
  image                      = "${module.ecr.repository_urls["api"]}:latest"
  container_port             = 8080
  desired_count              = var.api_desired_count
  cpu                        = var.task_cpu
  memory                     = var.task_memory
  https_listener_arn         = module.alb.https_listener_arn
  alb_security_group_id      = module.alb.alb_security_group_id
  host_header                = "api.${var.domain_name}"
  listener_rule_priority     = 10
  health_check_path          = "/health"
  database_security_group_id = module.database.db_security_group_id

  secret_arns = {
    PROVIDER_API_KEY = module.secrets.provider_api_key_secret_arn
    DATABASE_SECRET  = module.database.master_user_secret_arn
  }

  environment_variables = {
    DB_HOST     = module.database.db_endpoint
    ENVIRONMENT = var.environment
  }

  datadog_api_key_secret_arn = module.secrets.datadog_api_key_secret_arn
  log_retention_days         = var.log_retention_days
  tags                       = var.tags
}

module "web" {
  source = "../../modules/service"

  name_prefix            = var.name_prefix
  environment            = var.environment
  service_name           = "web"
  cluster_arn            = module.ecs_cluster.cluster_arn
  vpc_id                 = module.network.vpc_id
  private_subnet_ids     = module.network.private_subnet_ids
  image                  = "${module.ecr.repository_urls["web"]}:latest"
  container_port         = 3000
  desired_count          = var.web_desired_count
  cpu                    = var.task_cpu
  memory                 = var.task_memory
  https_listener_arn     = module.alb.https_listener_arn
  alb_security_group_id  = module.alb.alb_security_group_id
  host_header            = "app.${var.domain_name}"
  listener_rule_priority = 20
  health_check_path      = "/healthz"

  environment_variables = {
    API_URL     = "https://api.${var.domain_name}"
    ENVIRONMENT = var.environment
  }

  datadog_api_key_secret_arn = module.secrets.datadog_api_key_secret_arn
  log_retention_days         = var.log_retention_days
  tags                       = var.tags
}

module "worker" {
  source = "../../modules/worker"

  name_prefix                = var.name_prefix
  environment                = var.environment
  cluster_arn                = module.ecs_cluster.cluster_arn
  vpc_id                     = module.network.vpc_id
  private_subnet_ids         = module.network.private_subnet_ids
  image                      = "${module.ecr.repository_urls["worker"]}:latest"
  desired_count              = var.worker_desired_count
  cpu                        = var.task_cpu
  memory                     = var.task_memory
  sweep_schedule_expression  = var.reminder_sweep_expression
  database_security_group_id = module.database.db_security_group_id

  secret_arns = {
    PROVIDER_API_KEY = module.secrets.provider_api_key_secret_arn
    DATABASE_SECRET  = module.database.master_user_secret_arn
  }

  environment_variables = {
    DB_HOST     = module.database.db_endpoint
    ENVIRONMENT = var.environment
  }

  datadog_api_key_secret_arn = module.secrets.datadog_api_key_secret_arn
  log_retention_days         = var.log_retention_days
  tags                       = var.tags
}

module "observability" {
  source = "../../modules/observability"

  name_prefix                 = var.name_prefix
  environment                 = var.environment
  pagerduty_notification      = var.datadog_pagerduty_notification
  slack_warning_channel       = var.datadog_slack_warning
  slack_info_channel          = var.datadog_slack_info
  api_availability_slo_target = var.api_availability_slo_target
  reminder_latency_slo_target = var.reminder_latency_slo_target
  enable_paging               = var.datadog_enable_paging
  tags                        = ["env:${var.environment}", "project:acme"]
}

module "ci_oidc" {
  source = "../../modules/ci-oidc"

  name_prefix = var.name_prefix
  environment = var.environment
  github_org  = var.github_org
  github_repo = var.github_repo

  # prod is its own account and narrows the apply role to the "prod" GitHub
  # environment, so it can only be assumed from an approved deployment.
  create_oidc_provider   = true
  prod_environment_claim = "prod"

  tags = var.tags
}
