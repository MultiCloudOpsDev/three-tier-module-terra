
# ─────────────────────────────
# VPC
# ─────────────────────────────
module "vpc" {
  source   = "../ROOT-MODULE/VPC"
aws_region =var.aws_region
vpc_cidr = var.vpc_cidr
tags = var.tags
public_subnet_1_cidr = var.public_subnet_1_cidr
public_subnet_2_cidr = var.public_subnet_2_cidr
private_subnet_1_cidr = var.private_subnet_1_cidr
private_subnet_2_cidr = var.private_subnet_2_cidr
private_subnet_3_cidr = var.private_subnet_3_cidr
private_subnet_4_cidr = var.private_subnet_4_cidr
private_subnet_5_cidr = var.private_subnet_5_cidr
private_subnet_6_cidr = var.private_subnet_6_cidr
availability_zone_1a = var.availability_zone_1a
availability_zone_1b = var.availability_zone_1b
vpc_id            = module.vpc.vpc_id
 allowed_ssh_cidr = ["0.0.0.0/0"]   
}

# ────────────────────────────
# AWS Bastion Host
# ─────────────────────────────
module "bastion" {
  source = "../ROOT-MODULE/BASTION"
aws_region = var.aws_region
ami =var.ami
instance_type = var.instance_type
key =var.key
subnet_id = module.vpc.public_subnets[0]
security_group_id = module.vpc.bastion_sg_id
tags = var.tags
}

# ─────────────────────────────
# Frontend ALB
# ─────────────────────────────
module "frontend_alb" {
  source = "../ROOT-MODULE/LB-FRONTEND"
aws_region = var.aws_region
vpc_id = module.vpc.vpc_id
subnets = module.vpc.public_subnets
security_group_id = module.vpc.alb_frontend_sg_id
alb_name = "frontend-alb"
target_group_name = "frontend-tg"

}

# ─────────────────────────────
# Backend ALB
# ─────────────────────────────
module "backend_alb" {
  source            = "../ROOT-MODULE/LB-BACKEND"
 aws_region = var.aws_region
vpc_id = module.vpc.vpc_id
subnets = module.vpc.public_subnets
security_group_id = module.vpc.alb_backend_sg_id
alb_name = "backend-alb"
target_group_name = "backend-tg"
}

# ─────────────────────────────
# Frontend  and backend Launch Template
# ─────────────────────────────
module "frontend_and_backend_lt" {

  source        = "../ROOT-MODULE/LAUNCH-TEMPLATE"
  aws_region   = var.aws_region
#  = "three-tier"
project_name = "three-tier"
frontend_ami   = "frontend-ami"
backend_ami    = "backend-ami"
instance_type  = var.instance_type
frontend_sg_id = module.vpc.frontend_server_sg_id
backend_sg_id  = module.vpc.backend_server_sg_id
key_name       = var.key

}

# ────────────────────────────
# Auto Scaling Group (App  and web Tier)
# ─────────────────────────────

module "asg" {
    source     = "../ROOT-MODULE/ASG"
aws_region = var.aws_region
tags = "books-three-tier"

# Frontend
frontend_launch_template_id = module.frontend_and_backend_lt.frontend_launch_template_id
web_subnet_1_id             = module.vpc.public_subnets[0]
web_subnet_2_id             = module.vpc.public_subnets[1]
frontend_target_group_arn   = module.frontend_alb.alb_target_group_arn

frontend_desired_capacity = 1
frontend_min_size         = 1
frontend_max_size         = 3

# Backend
backend_launch_template_id = module.frontend_and_backend_lt.backend_launch_template_id
app_subnet_1_id            = module.vpc.private_app_subnets[0]
app_subnet_2_id            = module.vpc.private_app_subnets[1]
backend_target_group_arn   = module.backend_alb.alb_target_group_arn
backend_desired_capacity = 1
backend_min_size         = 1
backend_max_size         = 3
# Scaling
scale_out_target_value = 80

}

# ─────────────────────────────
# RDS (DB Tier)
# ─────────────────────────────
module "rds" {
source         = "../ROOT-MODULE/RDS"
aws_region   = var.aws_region
tags = "three-tier"
identifier   = "book-rds"
allocated_storage = 20
engine            = "mysql"
engine_version    = "8.0"
instance_class    = var.instance_class
multi_az          = false
db_name           = var.db_name
db_username       = var.db_username
db_password       = var.db_password
db_subnet_1_id    = module.vpc.private_db_subnets[0]
db_subnet_2_id    = module.vpc.private_db_subnets[1]
rds_sg_id         = module.vpc.database_sg_id
}


# module "route53" {
#   source = "../ROOT-MODULE/route53"

#   domain_name = "shrii.shop"
#   vpc_id      = module.vpc.vpc_id

#   frontend_dns_name  = "shrii.shop"
#   frontend_alb_dns   = module.frontend_alb.alb_dns_name
#   frontend_alb_zone_id = module.frontend_alb.alb_zone.id

#   backend_dns_name   = "backend.shrii.shop"
#   backend_alb_dns    = module.backend_alb.alb_dns_name
#   backend_alb_zone_id = module.backend_alb.alb_zone_id
  

#   rds_dns_name = "rds.shrii.shop"
#   rds_endpoint = module.rds.rds_endpoint
# }




#terraform plan -target=module.vpc