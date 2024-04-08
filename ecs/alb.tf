resource "aws_security_group" "vacgom-alb-sg" {
  name = "vacgom-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "ALL"

    cidr_blocks = var.private_subnet_cidr_blocks
  }
  tags = {
    Name = "vacgom-alb-sg"
  }
}


resource "aws_alb" "vacgom-alb-2" {
  name = "vacgom-alb-2"
  internal = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.vacgom-alb-sg.id]
  subnets = var.public_subnet_ids
}
