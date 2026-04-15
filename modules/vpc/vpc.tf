# Create VPC Terraform Module
module "vpc" {
source  = "terraform-aws-modules/vpc/aws"
version = "6.6.0"

## VPC BASIC INFORMATION
name = var.vpc_name
cidr = var.vpc_cidr_block
## Availability Zones and Subnets
azs              = var.vpc_availability_zones
public_subnets   = var.vpc_public_subnets
private_subnets = var.vpc_private_subnets
database_subnets = var.vpc_database_subnets

## Internet + NAT
  enable_nat_gateway = true
  single_nat_gateway = true

## Enable DNS Hostnames and Support
create_database_subnet_group = true
create_database_subnet_route_table = true
enable_dns_hostnames = true
enable_dns_support   = true

tags = var.tags
}