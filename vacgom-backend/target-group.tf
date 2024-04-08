resource "aws_lb_target_group" "vacgom-target-group" {
  name = "vacgom-target-group"
  port = 8080
  protocol = "HTTP"
  vpc_id = var.vpc-id

  health_check {
    path = "/"
    protocol = "HTTP"
    timeout = 5
    interval = 30
  }
}

resource "aws_lb_listener" "vacgom-alb-listener" {
  depends_on = [aws_lb_target_group.vacgom-target-group]

  load_balancer_arn = var.vacgom-alb-id

  port = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vacgom-target-group.arn
  }
}

