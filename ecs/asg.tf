resource "aws_autoscaling_group" "ecs-ec2-asg" {
  depends_on = [aws_launch_template.ecs-ec2]

  name                  = "vacgom-ecs-ec2-asg"
  vpc_zone_identifier   = var.private_vpc_zone_ids
  min_size              = 0
  max_size              = 3
  desired_capacity_type = "units"

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "lowest-price"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.ecs-ec2.id
        version            = "$Latest"
      }

      override {
        instance_type     = "t2.medium"
        weighted_capacity = "1"
      }
    }
  }
}
