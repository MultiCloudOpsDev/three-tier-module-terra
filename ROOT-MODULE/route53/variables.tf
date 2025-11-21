variable "domain_name" {
  description = "Hosted zone domain"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to attach private zone"
  type        = string
}

# Frontend ALB variables
variable "frontend_dns_name" {
  type        = string
  description = "Frontend DNS record (ex: shrii.shop)"
}

variable "frontend_alb_dns" {
  type        = string
  description = "Frontend ALB DNS name"
}

variable "frontend_alb_zone_id" {
  type        = string
  description = "Frontend ALB Zone ID"
}

# Backend ALB variables
variable "backend_dns_name" {
  type        = string
  description = "Backend DNS record (ex: backend.shrii.shop)"
}

variable "backend_alb_dns" {
  type        = string
  description = "Backend ALB DNS name"
}

variable "backend_alb_zone_id" {
  type        = string
  description = "Backend ALB Zone ID"
}

# RDS variables
variable "rds_endpoint" {
  type        = string
  description = "RDS endpoint"
}

variable "rds_dns_name" {
  type        = string
  description = "DB DNS record (ex: rds.shrii.shop)"
}
