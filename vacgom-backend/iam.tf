data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vacgom-task-execution-role" {
  name = "vacgom-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "vacgom-task-execution-role-policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.vacgom-task-execution-role.name
}
