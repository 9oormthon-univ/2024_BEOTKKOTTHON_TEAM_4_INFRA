resource "aws_lb_target_group" "vacgom-target-group" {
  name     = "vacgom-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc-id

  health_check {
    path     = "/actuator/health"
    protocol = "HTTP"
    timeout  = 5
    interval = 30
  }
}

data "aws_acm_certificate" "vacgom-cert" {
  domain = var.vacgom-domain
}

resource "aws_lb_listener" "vacgom-alb-listener" {
  depends_on = [aws_lb_target_group.vacgom-target-group]

  load_balancer_arn = var.vacgom-alb-id

  port     = 443
  protocol = "HTTPS"

  certificate_arn = data.aws_acm_certificate.vacgom-cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vacgom-target-group.arn
  }
}

resource "aws_alb_listener" "vacgom-alb-listener-80" {
  depends_on        = [aws_lb_listener.vacgom-alb-listener]
  load_balancer_arn = var.vacgom-alb-id

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

data "aws_route53_zone" "vacgom-zone" {
  name = var.vacgom-zone
}
data "aws_lb" "vacgom-alb" {
  arn = var.vacgom-alb-id
}

resource "aws_route53_record" "vacgom-route" {
  zone_id = data.aws_route53_zone.vacgom-zone.id
  name    = "api-dev.${var.vacgom-zone}"
  type    = "CNAME"
  ttl     = 300
  records = [data.aws_lb.vacgom-alb.dns_name]
}
