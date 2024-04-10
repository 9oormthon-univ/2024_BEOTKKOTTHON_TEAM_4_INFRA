resource "aws_db_subnet_group" "vacgom-db-subnet-group" {
  subnet_ids = var.private-subnet-ids
}

resource "aws_security_group" "vacgom-db-sg" {
    name = "vacgom-db-sg"
    vpc_id = var.vpc-id

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = var.private-cidr-groups
    }
}

resource "aws_db_instance" "vacgom-db" {
  db_name = "vacgomdb"
  engine = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.t4g.micro"

  allocated_storage    = 10
  availability_zone = "ap-northeast-2a"

  username = "admin"
  manage_master_user_password = true

  vpc_security_group_ids = [aws_security_group.vacgom-db-sg.id]
  db_subnet_group_name = aws_db_subnet_group.vacgom-db-subnet-group.name
}

resource "aws_secretsmanager_secret_rotation" "vacgom-secret-rotation" {
  secret_id = aws_db_instance.vacgom-db.master_user_secret[0].secret_arn

  rotation_rules {
    automatically_after_days = 30
  }
}
