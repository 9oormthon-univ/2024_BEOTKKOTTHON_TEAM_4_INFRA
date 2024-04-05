resource "aws_ecs_cluster" "vacgom-cluster" {
  name = "vacgom-cluster-terraform"
}

resource "aws_ecs_capacity_provider" "vacgom-capacity-provider" {
  depends_on = [aws_autoscaling_group.ecs-ec2-asg]

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
  depends_on = [aws_ecs_capacity_provider.vacgom-capacity-provider, aws_ecs_cluster.vacgom-cluster]
  cluster_name = aws_ecs_cluster.vacgom-cluster.name

  capacity_providers = [aws_ecs_capacity_provider.vacgom-capacity-provider.name]
}
