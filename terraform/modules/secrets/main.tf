# Module: secrets
# Secrets Manager secret containers for the third-party SMS/email provider API
# key and the Datadog API/app keys. Only the containers are created here; the
# actual values are set out-of-band (console/CLI) so no secret material ever
# lands in Terraform state or git history. Database master credentials are NOT
# created here — they are managed by the database module via RDS-managed passwords.

resource "aws_secretsmanager_secret" "provider_api_key" {
  name        = "${var.name_prefix}/provider-api-key"
  description = "Third-party SMS/email provider API key (value set out-of-band)"

  recovery_window_in_days = var.recovery_window_days

  tags = var.tags
}

resource "aws_secretsmanager_secret" "datadog_api_key" {
  name        = "${var.name_prefix}/datadog-api-key"
  description = "Datadog API key (value set out-of-band)"

  recovery_window_in_days = var.recovery_window_days

  tags = var.tags
}

resource "aws_secretsmanager_secret" "datadog_app_key" {
  name        = "${var.name_prefix}/datadog-app-key"
  description = "Datadog application key (value set out-of-band)"

  recovery_window_in_days = var.recovery_window_days

  tags = var.tags
}
