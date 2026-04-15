## VPC Variables
vpc_name = "my-vpc"
vpc_cidr_block = "10.0.0.0/16"
vpc_availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
vpc_private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
vpc_database_subnets = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
vpc_create_database_subnet_group = true 
vpc_create_database_subnet_route_table = true   
vpc_enable_nat_gateway = true  
vpc_single_nat_gateway = true
ami_id = "ami-0c3389a4fa5bddaad"
domain_name = "mbodou.org"
github_owner  = "mahamatmbodou33"
github_repo   = "YOUR_REPO_NAME"