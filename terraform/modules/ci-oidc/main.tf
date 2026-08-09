# Module: ci-oidc
# The GitHub Actions -> AWS trust path. An IAM OIDC provider for GitHub Actions
# and two roles: a read-only plan role and a scoped apply role. Both trust
# policies are conditioned on the specific repository; the prod apply role is
# further narrowed to a GitHub environment claim so it can only be assumed from an
# approved deployment. No long-lived access keys exist anywhere.

locals {
  oidc_url  = "https://token.actions.githubusercontent.com"
  oidc_host = "token.actions.githubusercontent.com"

  repo_sub = "repo:${var.github_org}/${var.github_repo}"

  # Apply role subject: narrowed to a GitHub environment when a claim is set
  # (prod), otherwise any ref in the repo (non-prod).
  apply_sub = var.prod_environment_claim != "" ? "${local.repo_sub}:environment:${var.prod_environment_claim}" : "${local.repo_sub}:*"

  provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url            = local.oidc_url
  client_id_list = ["sts.amazonaws.com"]

  # thumbprint_list intentionally omitted: for the GitHub Actions provider AWS
  # validates the token against its own trust store, so a static thumbprint is no
  # longer required and would only rot.

  tags = var.tags
}

# When this env shares an account with another that already created the provider
# (staging shares the non-prod account with dev), look it up instead.
data "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 0 : 1

  url = local.oidc_url
}

# --- Trust policies ---

data "aws_iam_policy_document" "plan_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_host}:sub"
      values   = ["${local.repo_sub}:*"]
    }
  }
}

data "aws_iam_policy_document" "apply_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_host}:sub"
      values   = [local.apply_sub]
    }
  }
}

# --- Plan role: read-only, assumed on pull requests ---

resource "aws_iam_role" "plan" {
  name               = "${var.name_prefix}-gha-tf-plan"
  assume_role_policy = data.aws_iam_policy_document.plan_assume.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "plan_readonly" {
  role       = aws_iam_role.plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# --- Apply role: scoped to the services this stack manages ---

resource "aws_iam_role" "apply" {
  name               = "${var.name_prefix}-gha-tf-apply"
  assume_role_policy = data.aws_iam_policy_document.apply_assume.json

  tags = var.tags
}

# Scoped to the services this Terraform actually manages rather than
# AdministratorAccess. Still broad within those services; tightening to
# per-resource least privilege is a tracked evolution item.
data "aws_iam_policy_document" "apply" {
  statement {
    sid    = "ManageStackServices"
    effect = "Allow"
    actions = [
      "ec2:*",
      "rds:*",
      "ecs:*",
      "ecr:*",
      "elasticloadbalancing:*",
      "wafv2:*",
      "sqs:*",
      "scheduler:*",
      "secretsmanager:*",
      "logs:*",
      "cloudwatch:*",
      "iam:*",
      "application-autoscaling:*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "TerraformStateBackend"
    effect = "Allow"
    actions = [
      "s3:*",
      "dynamodb:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "apply" {
  name   = "terraform-apply"
  role   = aws_iam_role.apply.id
  policy = data.aws_iam_policy_document.apply.json
}
