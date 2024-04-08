resource "aws_ecs_cluster" "vacgom-cluster-2" {
  name = "vacgom-cluster-2"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_capacity_provider" "vacgom-capacity-provider" {
  depends_on = [aws_ecs_cluster.vacgom-cluster-2, aws_autoscaling_group.ecs-ec2-asg]

  name = "vacgom-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs-ec2-asg.arn

    managed_scaling {
        status = "ENABLED"
        target_capacity = 90
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "vacgom-cluster-capacity-providers" {
  depends_on = [aws_ecs_capacity_provider.vacgom-capacity-provider]

  cluster_name = aws_ecs_cluster.vacgom-cluster-2.name

  capacity_providers = [aws_ecs_capacity_provider.vacgom-capacity-provider.name]
}
