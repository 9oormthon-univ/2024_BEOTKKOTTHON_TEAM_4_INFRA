resource "aws_cloudwatch_log_group" "vacgom-logs" {
  name = "vacgom-log"
}

resource "aws_ecs_task_definition" "vacgom-taskdef" {
  depends_on = [aws_db_instance.vacgom-db]

  family                   = "vacgom-taskdef"
  track_latest             = true
  requires_compatibilities = ["EC2"]
  cpu                      = "2048"
  memory                   = "3500"
  tags                     = {
    Name = "vacgom-taskdef"
  }
  task_role_arn      = aws_iam_role.vacgom-task-execution-role.arn
  execution_role_arn = aws_iam_role.vacgom-task-execution-role.arn

  container_definitions = jsonencode([
    {
      name   = "vacgom-backend",
      image  = var.vacgom-container-image,
      cpu    = 2048,
      memory = 3000,

      essential    = true,
      portMappings = [
        {
          containerPort = 8080,
          hostPort      = 8080,
          protocol      = "tcp",
          appProtocol   = "http"
        }
      ],
      environment = [
        {
          name  = "SPRING_DATASOURCE_URL"
          value = "jdbc:mysql://${aws_db_instance.vacgom-db.address}:${aws_db_instance.vacgom-db.port}/vacgom?serverTimezone=UTC&useSSL=false"
        },
        {
          name  = "SPRING_DATASOURCE_USERNAME"
          value = "admin"
        }
      ],
      mountPoints    = [],
      volumesFrom    = [],
      systemControls = [],
      secrets        = [
        {
          name      = "SPRING_DATASOURCE_PASSWORD",
          valueFrom = aws_secretsmanager_secret_version.vacgom-db-password.arn
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          "awslogs-group"         = aws_cloudwatch_log_group.vacgom-logs.name
          "awslogs-region"        = "ap-northeast-2"
          "awslogs-stream-prefix" = "vacgom-backend"
        }
      }
    }
  ])
}
