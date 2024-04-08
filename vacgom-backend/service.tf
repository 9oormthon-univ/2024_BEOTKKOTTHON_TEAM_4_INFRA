resource "aws_ecs_service" "vacgom-backend-service" {
  depends_on = [aws_lb_target_group.vacgom-target-group]

  name = "vacgom-backend-service"

  cluster = var.vacgom-cluster-name
  task_definition = aws_ecs_task_definition.vacgom-taskdef.id

  desired_count = 1

  capacity_provider_strategy {
    capacity_provider = var.vacgom-capacity-provider-id[0]
    weight = 1
    base = 0
  }

  load_balancer {
    container_name = "vacgom-backend"
    container_port = 8080
    target_group_arn = aws_lb_target_group.vacgom-target-group.arn
  }
}
