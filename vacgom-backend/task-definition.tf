resource "aws_ecs_task_definition" "vacgom-taskdef" {
    family                = "vacgom-taskdef"
    track_latest = true
    requires_compatibilities = ["EC2"]
    cpu = "1024"
    memory = "800"
    tags = {
      Name = "vacgom-taskdef"
    }
    task_role_arn = aws_iam_role.vacgom-task-execution-role.arn

    container_definitions = jsonencode([
      {
        name = "vacgom-backend",
        image = var.vacgom-container-image,
        cpu = 1,
        memory = 800,
        essential = true,
        portMappings = [
          {
            containerPort = 8080,
            hostPort = 8080,
            protocol = "tcp",
            appProtocol = "http"
          }
        ],
        environment = [],
        mountPoints = [],
        volumesFrom = [],
        systemControls = []
      }
    ])
}
