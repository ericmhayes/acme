# Module: ecs-cluster
# A single ECS cluster running Fargate, with Container Insights enabled. The
# cluster is shared by the api, web, and worker services; per-service task roles
# and definitions live in the service/worker modules.

resource "aws_ecs_cluster" "this" {
  name = "${var.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }

  tags = var.tags
}
