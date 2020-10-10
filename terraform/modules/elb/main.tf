data "aws_route53_zone" "selected" {
  zone_id = var.hosted_zone_id
}

resource "aws_acm_certificate" "elb_cert" {
  domain_name = data.aws_route53_zone.selected.name
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
      for dvo in aws_acm_certificate.elb_cert.domain_validation_options : dvo.domain_name => {
        name = dvo.resource_record_name
        record = dvo.resource_record_value
        type = dvo.resource_record_type
      }
    }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

resource "aws_acm_certificate_validation" "elb_cert" {
  certificate_arn = aws_acm_certificate.elb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_lb" "elb" {
  name               = "dev-to"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [
    var.load_balancer_sg.id]
  subnets            = [
    var.load_balancer_subnet_a.id,
    var.load_balancer_subnet_b.id,
    var.load_balancer_subnet_c.id]
}

resource "aws_lb_target_group" "ecs" {
  name     = "ecs"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.elb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   =aws_acm_certificate_validation.elb_cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
