resource "aws_db_subnet_group" "vacgom-db-subnet-group" {
  subnet_ids = var.private-subnet-ids
}

resource "aws_security_group" "vacgom-db-sg" {
  name   = "vacgom-db-sg"
  vpc_id = var.vpc-id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "vacgom-db" {
  db_name        = "vacgomdb"
  engine         = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.t4g.micro"

  allocated_storage = 10
  availability_zone = "ap-northeast-2a"

  username = "admin"
  password = var.vacgom-db-password

  vpc_security_group_ids = [aws_security_group.vacgom-db-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.vacgom-db-subnet-group.name
}

resource "aws_secretsmanager_secret" "vacgom-db-password" {
  name = "vacgom-db-password"
}

resource "aws_secretsmanager_secret_version" "vacgom-db-password" {
  secret_id     = aws_secretsmanager_secret.vacgom-db-password.id
  secret_string = var.vacgom-db-password
}

data "aws_iam_policy_document" "vacgom-db-policy" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      aws_secretsmanager_secret.vacgom-db-password.id
    ]
  }

}

resource "aws_iam_policy" "vacgom-db-policy" {
  name        = "vacgom-secret-policy"
  description = "Allow vacgom ecs task to access vacgom secret"
  policy      = data.aws_iam_policy_document.vacgom-db-policy.json

}

resource "aws_iam_role_policy_attachment" "vacgom-db-policy" {
  policy_arn = aws_iam_policy.vacgom-db-policy.arn
  role       = aws_iam_role.vacgom-task-execution-role.id
}
