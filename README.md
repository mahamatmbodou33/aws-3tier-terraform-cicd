# Terraform AWS 3-Tier Architecture v2

This project demonstrates a production-style 3-tier architecture on AWS using Terraform.

## Features
- Remote state with S3 and DynamoDB
- Public Terraform modules for VPC and ALB
- HTTPS listener with ACM certificate
- Local custom modules for bastion, EC2 app, and RDS
- Separate dev and prod environments
- Secure network segmentation across public, private, and database subnets

## Architecture
Internet -> Application Load Balancer (HTTPS) -> EC2 App Tier -> RDS MySQL

## Skills Demonstrated
- Terraform
- AWS VPC
- ALB
- ACM
- HTTPS
- EC2
- RDS
- Bastion Host
- Remote State
- Infrastructure as Code