# Architecture Notes

## Public Modules
- terraform-aws-modules/vpc/aws
- terraform-aws-modules/alb/aws

## Local Modules
- bastion
- ec2-app
- rds

## Network Layout
- Public subnets: ALB, Bastion
- Private subnets: Application servers
- Database subnets: RDS

## Security Design
- ALB accepts HTTP and HTTPS
- HTTP redirects to HTTPS
- App instances accept traffic only from ALB
- SSH access to app instances only from bastion
- RDS access only from app security group

## Remote State
- S3 bucket stores Terraform state
- DynamoDB table provides locking

## Environments
- dev
- prod