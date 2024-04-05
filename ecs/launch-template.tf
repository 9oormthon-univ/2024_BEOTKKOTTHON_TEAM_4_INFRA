data "aws_ssm_parameter" "ecs-ec2-iam" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs-ec2" {
  depends_on = [aws_security_group.ecs-node-sg]

  name = "vacgom-ecs-ec2"
  image_id = data.aws_ssm_parameter.ecs-ec2-iam.value

  vpc_security_group_ids = [aws_security_group.ecs-node-sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs-instance-profile.name
  }

  monitoring {
    enabled = true
  }

  key_name = "vacgom"

  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.vacgom-cluster.name} >> /etc/ecs/ecs.config;
  EOF
  )
}
