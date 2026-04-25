module "vpc" {
  source                                 = "../../modules/vpc"
  vpc_name                               = "${local.name_prefix}-vpc"
  vpc_cidr_block                         = var.vpc_cidr_block
  vpc_availability_zones                 = var.vpc_availability_zones
  vpc_public_subnets                     = var.vpc_public_subnets
  vpc_private_subnets                    = var.vpc_private_subnets
  vpc_database_subnets                   = var.vpc_database_subnets
  vpc_create_database_subnet_group       = var.vpc_create_database_subnet_group
  vpc_create_database_subnet_route_table = var.vpc_create_database_subnet_route_table
  vpc_enable_nat_gateway                 = var.vpc_enable_nat_gateway
  vpc_single_nat_gateway                 = var.vpc_single_nat_gateway

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
  source          = "../../modules/alb"
  name            = "${local.name_prefix}-alb"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  alb_sg_id       = module.sg.alb_sg_id
  certificate_arn = module.acm.certificate_arn
  tags            = local.common_tags
}

module "app1" {
  source                = "../../modules/app"
  name                  = "mbodou-dev-app1"
  app_name              = "app1"
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  subnet_ids            = module.vpc.private_subnets
  security_group_ids    = [module.sg.app_sg_id]
  target_group_arn      = module.alb.target_group_arn_app1
  desired_capacity      = 2
  min_size              = 1
  max_size              = 3
  instance_profile_name = module.iam.instance_profile_name
  artifact_bucket       = aws_s3_bucket.artifacts.bucket
  artifact_key          = "app1/app1.zip"

  tags = {
    Project     = "mbodou"
    Environment = "dev"
    App         = "app1"
    ManagedBy   = "Terraform"
  }
}

module "app2" {
  source                = "../../modules/app"
  name                  = "mbodou-dev-app2"
  app_name              = "app2"
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  subnet_ids            = module.vpc.private_subnets
  security_group_ids    = [module.sg.app_sg_id]
  target_group_arn      = module.alb.target_group_arn_app2
  desired_capacity      = 2
  min_size              = 1
  max_size              = 3
  instance_profile_name = module.iam.instance_profile_name
  artifact_bucket       = aws_s3_bucket.artifacts.bucket
  artifact_key          = "app2/app2.zip"

  tags = {
    Project     = "mbodou"
    Environment = "dev"
    App         = "app2"
    ManagedBy   = "Terraform"
    TestRun =  "final-ci-cd-test"
  }
}

# RDS
module "rds" {
  source     = "../../modules/rds"
  name       = "${local.name_prefix}-db"
  db_subnets = module.vpc.database_subnets
  db_sg_id   = module.sg.db_sg_id
  tags       = local.common_tags
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

# WAF for ALB
module "waf" {
  source = "../../modules/WAF"

  name    = "three-tier-waf"
  alb_arn = module.alb.alb_arn
}

# Monitoring and Alerting
module "monitoring" {
  source = "../../modules/monitoring"

  project_name                 = var.project_name
  environment                  = var.environment
  alb_arn_suffix               = module.alb.alb_arn_suffix
  app1_target_group_arn_suffix = module.alb.target_group_arn_suffix_app1
  app2_target_group_arn_suffix = module.alb.target_group_arn_suffix_app2
  web_acl_name                 = module.waf.web_acl_name
  alert_email                  = var.alert_email

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

## S3 Bucket for Application Artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket = "mbodou-dev-artifacts"

  tags = {
    Name        = "mbodou-dev-artifacts"
    Environment = "dev"
  }
}