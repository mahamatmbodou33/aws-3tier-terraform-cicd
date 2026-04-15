module "vpc" {
  source = "../../modules/vpc"
  vpc_name = "${local.name_prefix}-vpc"
  vpc_cidr_block = var.vpc_cidr_block
  vpc_availability_zones = var.vpc_availability_zones
  vpc_public_subnets = var.vpc_public_subnets
  vpc_private_subnets = var.vpc_private_subnets
  vpc_database_subnets = var.vpc_database_subnets
  vpc_create_database_subnet_group = var.vpc_create_database_subnet_group
  vpc_create_database_subnet_route_table = var.vpc_create_database_subnet_route_table
  vpc_enable_nat_gateway = var.vpc_enable_nat_gateway
  vpc_single_nat_gateway = var.vpc_single_nat_gateway
  
tags = local.common_tags
}

# IAM MODULES

module "iam" {
  source              = "../../modules/iam"
  project_name        = var.project_name
  environment         = var.environment
  artifact_bucket_arn = aws_s3_bucket.artifacts.arn
  github_owner        = var.github_owner
  github_repo         = var.github_repo
}

module "sg" {
  source = "../../modules/security-groups"
  vpc_id = module.vpc.vpc_id

}
# ALB
module "alb" {
  source = "../../modules/alb"
  name = "${local.name_prefix}-alb"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_sg_id      = module.sg.alb_sg_id
  certificate_arn = module.acm.certificate_arn
  tags = local.common_tags
}

module "app1" {
  source                = "../../modules/app"
  name                  = "${var.project_name}-${var.environment}-app1"
  app_name              = "app1"
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  subnet_ids            = module.vpc.private_app_subnet_ids
  security_group_ids    = [module.security_groups.app_sg_id]
  target_group_arn      = module.alb.app1_target_group_arn
  desired_capacity      = 2
  min_size              = 1
  max_size              = 3
  instance_profile_name = module.iam.instance_profile_name
  artifact_bucket       = aws_s3_bucket.artifacts.bucket
  artifact_key          = "app1/app1.zip"
  tags                  = local.common_tags

  depends_on = [module.alb]
}

module "app2" {
  source                = "../../modules/app"
  name                  = "${var.project_name}-${var.environment}-app2"
  app_name              = "app2"
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  subnet_ids            = module.vpc.private_app_subnet_ids
  security_group_ids    = [module.security_groups.app_sg_id]
  target_group_arn      = module.alb.app2_target_group_arn
  desired_capacity      = 2
  min_size              = 1
  max_size              = 3
  instance_profile_name = module.iam.instance_profile_name
  artifact_bucket       = aws_s3_bucket.artifacts.bucket
  artifact_key          = "app2/app2.zip"
  tags                  = local.common_tags

  depends_on = [module.alb]
}

# RDS
module "rds" {
  source = "../../modules/rds"
  name = "${local.name_prefix}-db"
  db_subnets = module.vpc.database_subnets
  db_sg_id   = module.sg.db_sg_id
  tags = local.common_tags
}

## ACM Certificate for ALB
module "acm" {
  source = "../../modules/acm"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.selected.zone_id

  tags = local.common_tags
}

# Route53 DNS Record for ALB
module "route53_dns" {
  source = "../../modules/route53-dns"

  domain_name = var.domain_name

  zone_id      = data.aws_route53_zone.selected.zone_id
  alb_dns_name = module.alb.dns_name
  alb_zone_id  = module.alb.zone_id
}

# WAF
module "waf" {
  source = "../../modules/WAF"

  name    = "three-tier-waf"
  alb_arn = module.alb.alb_arn
}

# Monitoring and Alerting
module "monitoring" {
  source = "../../modules/monitoring"

  alert_email = "mahamatmbodou33@gmail.com"   
  web_acl_name = "three-tier-waf"
  region       = "us-east-1"
}