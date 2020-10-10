data "aws_route53_zone" "selected" {
  zone_id  = var.hosted_zone_id
}

resource "aws_route53_record" "dev_to" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = data.aws_route53_zone.selected.name
  type    = "A"

  alias {
    name                   = var.elb.dns_name
    zone_id                = var.elb.zone_id
    evaluate_target_health = true
  }
}
