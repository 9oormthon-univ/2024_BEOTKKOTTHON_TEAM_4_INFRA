data "aws_iam_policy_document" "ecs-instance-role-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "ecs-instance-role" {
  name_prefix = "ecs-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ecs-instance-role-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.ecs-instance-role.name
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs-instance-role.name
}
