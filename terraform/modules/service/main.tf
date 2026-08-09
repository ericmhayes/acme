# Module: service
# One load-balanced Fargate service (used for both the api and the web app). Owns
# its task definition, a least-privilege task role and execution role, a security
# group accepting traffic only from the ALB, its own target group, a host-header
# rule on the shared ALB listener, a CloudWatch log group, and secret injection
# via the task definition. A Datadog agent sidecar ships metrics/APM. No
# autoscaling (fixed desired_count) — deliberately right-sized for current volume.

data "aws_region" "current" {}

locals {
  app_environment = [for k, v in var.environment_variables : { name = k, value = v }]
  app_secrets     = [for k, v in var.secret_arns : { name = k, valueFrom = v }]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/acme/${var.environment}/${var.service_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# --- IAM ---

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
  name               = "${var.name_prefix}-${var.service_name}-exec"
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

# Task role starts empty (least privilege); app-specific permissions are added
# here as concrete needs appear.
resource "aws_iam_role" "task" {
  name               = "${var.name_prefix}-${var.service_name}-task"
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = var.tags
}

# --- Networking ---

resource "aws_security_group" "service" {
  name        = "${var.name_prefix}-${var.service_name}"
  description = "Tasks for ${var.service_name}; ingress from the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "From ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-${var.service_name}" })
}

resource "aws_security_group_rule" "to_database" {
  count = var.database_security_group_id == "" ? 0 : 1

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.database_security_group_id
  source_security_group_id = aws_security_group.service.id
  description              = "Postgres from ${var.service_name}"
}

# --- Load balancing ---

resource "aws_lb_target_group" "this" {
  name        = "${var.name_prefix}-${var.service_name}"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = var.tags
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.https_listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = [var.host_header]
    }
  }
}

# --- Task definition & service ---

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name_prefix}-${var.service_name}"
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
      name      = var.service_name
      image     = var.image
      essential = true

      portMappings = [{
        containerPort = var.container_port
        protocol      = "tcp"
      }]

      environment = local.app_environment
      secrets     = local.app_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = var.service_name
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
        { name = "DD_SERVICE", value = var.service_name },
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
  name            = var.service_name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.service.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener_rule.this]
}
