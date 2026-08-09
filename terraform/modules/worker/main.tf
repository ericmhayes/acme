# Module: worker
# The reminder pipeline. An always-on Fargate service (no ALB) that consumes an
# SQS queue; an EventBridge Scheduler that fires on an interval to enqueue a sweep
# message; an SQS main queue plus a dead-letter queue with a redrive policy; and a
# least-privilege task role scoped to exactly this queue and its secrets. The
# sweeper queries appointments whose reminder is due and not yet sent, so the
# database stays the single source of truth. A Datadog agent sidecar ships APM.

data "aws_region" "current" {}

locals {
  app_environment = [for k, v in var.environment_variables : { name = k, value = v }]
  app_secrets     = [for k, v in var.secret_arns : { name = k, valueFrom = v }]
}

# --- Queues ---

resource "aws_sqs_queue" "dlq" {
  name                      = "${var.name_prefix}-reminders-dlq"
  message_retention_seconds = 1209600 # 14 days

  tags = var.tags
}

resource "aws_sqs_queue" "main" {
  name                       = "${var.name_prefix}-reminders"
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.dlq_max_receive_count
  })

  tags = var.tags
}

# --- Logging ---

resource "aws_cloudwatch_log_group" "this" {
  name              = "/acme/${var.environment}/worker"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# --- IAM: task execution + task role ---

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.name_prefix}-worker-exec"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "execution_secrets" {
  name = "read-secrets"
  role = aws_iam_role.execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = concat(values(var.secret_arns), [var.datadog_api_key_secret_arn])
    }]
  })
}

resource "aws_iam_role" "task" {
  name               = "${var.name_prefix}-worker-task"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = var.tags
}

resource "aws_iam_role_policy" "task_sqs" {
  name = "consume-reminders"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility",
      ]
      Resource = aws_sqs_queue.main.arn
    }]
  })
}

# --- Networking ---

resource "aws_security_group" "worker" {
  name        = "${var.name_prefix}-worker"
  description = "Reminder worker tasks; egress only"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-worker" })
}

resource "aws_security_group_rule" "to_database" {
  count = var.database_security_group_id == "" ? 0 : 1

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.database_security_group_id
  source_security_group_id = aws_security_group.worker.id
  description              = "Postgres from reminder worker"
}

# --- Task definition & service ---

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name_prefix}-worker"
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = "worker"
      image     = var.image
      essential = true

      environment = concat(local.app_environment, [
        { name = "REMINDER_QUEUE_URL", value = aws_sqs_queue.main.url },
      ])
      secrets = local.app_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "worker"
        }
      }
    },
    {
      name      = "datadog-agent"
      image     = "public.ecr.aws/datadog/agent:7"
      essential = false

      environment = [
        { name = "ECS_FARGATE", value = "true" },
        { name = "DD_APM_ENABLED", value = "true" },
        { name = "DD_ENV", value = var.environment },
        { name = "DD_SERVICE", value = "worker" },
      ]

      secrets = [
        { name = "DD_API_KEY", valueFrom = var.datadog_api_key_secret_arn },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "datadog-agent"
        }
      }
    },
  ])

  tags = var.tags
}

resource "aws_ecs_service" "this" {
  name            = "worker"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.worker.id]
    assign_public_ip = false
  }
}

# --- EventBridge Scheduler: fires the sweep on an interval ---

data "aws_iam_policy_document" "scheduler_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "scheduler" {
  name               = "${var.name_prefix}-reminder-scheduler"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume.json

  tags = var.tags
}

resource "aws_iam_role_policy" "scheduler" {
  name = "enqueue-sweep"
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sqs:SendMessage"]
      Resource = aws_sqs_queue.main.arn
    }]
  })
}

resource "aws_scheduler_schedule" "sweep" {
  name = "${var.name_prefix}-reminder-sweep"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.sweep_schedule_expression

  target {
    arn      = aws_sqs_queue.main.arn
    role_arn = aws_iam_role.scheduler.arn
    input    = jsonencode({ action = "sweep" })
  }
}
