output "private_zone_id" {
  value = aws_route53_zone.private_zone.zone_id
}

output "frontend_fqdn" {
  value = aws_route53_record.frontend_dns.fqdn
}

output "backend_fqdn" {
  value = aws_route53_record.backend_dns.fqdn
}

output "rds_fqdn" {
  value = aws_route53_record.rds_record.fqdn
}
