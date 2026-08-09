# Root module: staging (non-prod account)
#
# Composes the shared modules for the staging environment. Module wiring is added
# in Phases 2-4; this file currently establishes the backend and provider only.
# Staging shares the non-prod account with dev but is isolated by VPC and IAM.

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
