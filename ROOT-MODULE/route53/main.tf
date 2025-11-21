# Use existing public hosted zone
data "aws_route53_zone" "existing_public" {
  name         = var.domain_name
  private_zone = false
}

# Public Frontend DNS → ALB
resource "aws_route53_record" "frontend_dns" {
  zone_id = data.aws_route53_zone.existing_public.zone_id
  name    = var.frontend_dns_name
  type    = "A"

  alias {
    name                   = var.frontend_alb_dns
    zone_id                = var.frontend_alb_zone_id
    evaluate_target_health = true
  }
}

# Public Backend DNS → ALB
resource "aws_route53_record" "backend_dns" {
  zone_id = data.aws_route53_zone.existing_public.zone_id
  name    = var.backend_dns_name
  type    = "A"

  alias {
    name                   = var.backend_alb_dns
    zone_id                = var.backend_alb_zone_id
    evaluate_target_health = true
  }
}

# Create Private Hosted Zone for RDS internal access
resource "aws_route53_zone" "private_zone" {
  name = var.domain_name

  vpc {
    vpc_id = var.vpc_id
  }

  comment       = "Private DNS zone for internal RDS"
  force_destroy = true
}

# Private DNS → RDS Endpoint
resource "aws_route53_record" "rds_record" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = var.rds_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [var.rds_endpoint]
}
