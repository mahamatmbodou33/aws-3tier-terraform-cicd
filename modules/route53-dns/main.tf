resource "aws_route53_record" "root" {
  zone_id = var.zone_id
  name    = "mbodou.org"
  type    = "A"
  
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}

resource "aws_route53_record" "app1" {
  zone_id = var.zone_id
  name    = "app1.mbodou.org"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }

  allow_overwrite = true
}
resource "aws_route53_record" "app2" {
  zone_id = var.zone_id
  name    = "app2.mbodou.org"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }

  allow_overwrite = true
}