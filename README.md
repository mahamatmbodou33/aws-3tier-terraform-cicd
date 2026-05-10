# Architecture Overview

## Project Summary

This project is a production-style AWS 3-tier architecture built with Terraform and GitHub Actions CI/CD.

The goal of the project is to demonstrate secure, scalable, and automated cloud infrastructure using real-world AWS services and Infrastructure as Code best practices.

---

## High-Level Architecture

Users access the application through custom domain names managed by Route 53. Route 53 resolves the domains to an Application Load Balancer.

The Application Load Balancer handles HTTPS traffic using an ACM certificate and routes requests to the correct application using host-based routing.

The application servers run on EC2 instances inside private subnets. These instances are managed by Auto Scaling Groups and are not directly accessible from the internet.

AWS Systems Manager Session Manager is used for secure private instance access without SSH or a bastion host.

---

## Request Flow

```text
User
  ↓
Route 53 DNS
  ↓
Application Load Balancer HTTPS via ACM
  ↓
AWS WAF attached to ALB
  ↓
Target Groups
  ↓
Auto Scaling Groups
  ↓
Private EC2 Application Servers
3-Tier VPC Design

The VPC is designed across multiple Availability Zones and separated into three tiers.

Public Tier

The public tier contains internet-facing resources.

Components:

Application Load Balancer
Internet Gateway
NAT Gateway if enabled
Public subnets across multiple Availability Zones
Private Application Tier

The private application tier contains the application servers.

Components:

EC2 instances
Auto Scaling Groups
Launch Templates
Security groups allowing traffic only from the ALB
SSM Session Manager access
Database Tier

The database tier is isolated from public access.

Components:

Database subnets
RDS-ready subnet group
Security group-controlled access
Load Balancer and Routing

The Application Load Balancer uses host-based routing to serve multiple applications from a single ALB.

Example routing:

app1.mbodou.org → Target Group App1
app2.mbodou.org → Target Group App2
mbodou.org      → Default response

Benefits:

Supports multiple applications behind one load balancer
Reduces cost compared to separate ALBs
Demonstrates Layer 7 routing
Allows clean domain-based service separation
Auto Scaling and Self-Healing

Each application is deployed behind its own Auto Scaling Group.

The Auto Scaling Groups provide:

High availability
Automatic instance replacement
Rolling deployment support
Self-healing when instances become unhealthy

If an EC2 instance fails its ALB health check, the Auto Scaling Group can replace it automatically.

Secure Access with SSM

The EC2 instances are deployed in private subnets and do not require public IP addresses.

Instead of SSH or a bastion host, this project uses AWS Systems Manager Session Manager.

Benefits:

No inbound SSH required
No bastion host to manage
Secure access to private instances
Better production security posture
Terraform Modular Design

The infrastructure is organized using reusable Terraform modules.

Example module structure:

modules/
├── acm
├── alb
├── app
├── iam
├── monitoring
├── rds
├── route53-dns
├── security-groups
├── vpc
└── WAF

Environment structure:

environments/
├── dev
└── prod

This design improves:

Maintainability
Reusability
Environment separation
Team collaboration
Production readiness
Terraform Remote State

Terraform state is stored remotely using Amazon S3.

DynamoDB is used for state locking.

Terraform
  ↓
S3 Backend Bucket
  ↓
DynamoDB Lock Table

Benefits:

Centralized state storage
Safe collaboration
Prevents concurrent Terraform runs
Supports CI/CD pipelines
CI/CD Architecture

This project includes separate CI/CD workflows for infrastructure and application deployments.

Infrastructure Pipeline

Terraform workflows manage AWS infrastructure.

Dev pipeline:

Push to main
  ↓
GitHub Actions
  ↓
Terraform fmt
  ↓
Terraform init
  ↓
Terraform validate
  ↓
Terraform plan/apply
  ↓
AWS infrastructure updated

Production pipeline:

Manual workflow trigger
  ↓
GitHub environment approval
  ↓
Terraform plan/apply
  ↓
Production infrastructure updated
Application Deployment Pipeline

Application code is packaged and deployed through S3 artifact storage.

App code change
  ↓
GitHub Actions
  ↓
Build app1.zip and app2.zip
  ↓
Upload artifacts to S3
  ↓
Trigger Auto Scaling instance refresh
  ↓
New EC2 instances download artifacts
  ↓
Application deployed
Artifact Deployment

Application artifacts are stored in an S3 bucket.

Example structure:

s3://artifact-bucket/
├── app1/app1.zip
└── app2/app2.zip

During EC2 bootstrap, user data downloads the correct artifact from S3 and deploys it to Apache.

Example flow:

EC2 User Data
  ↓
Download ZIP from S3
  ↓
Extract to /var/www/html
  ↓
Start Apache
  ↓
ALB health check passes
Monitoring and Alerting

CloudWatch is used for monitoring application and infrastructure health.

Monitoring includes:

ALB metrics
Target group health
Auto Scaling activity
WAF metrics
EC2 visibility

CloudWatch alarms can notify through SNS.

ALB / ASG / WAF
  ↓
CloudWatch Metrics
  ↓
CloudWatch Alarms
  ↓
SNS Email Notification
Security Features

Security-focused design choices include:

Private EC2 instances
No public SSH access
SSM Session Manager access
Security groups with restricted inbound access
IAM roles for EC2 and GitHub Actions
GitHub Actions OIDC authentication
AWS WAF protection
HTTPS using ACM
Terraform state locking
Dev and Prod Environments

The project separates development and production environments.

dev  → automatic testing and deployment
prod → manual approval-based deployment

Production uses GitHub Environment approval before deployment.

This provides a safer deployment model and demonstrates real-world CI/CD environment separation.

Key AWS Services Used
VPC
EC2
Auto Scaling Groups
Launch Templates
Application Load Balancer
Target Groups
Route 53
ACM
S3
DynamoDB
IAM
Systems Manager Session Manager
CloudWatch
SNS
AWS WAF
RDS-ready database subnets
Challenges Solved

During this project, several real-world issues were resolved:

Terraform backend configuration errors
S3 state checksum mismatch
DynamoDB state locking issues
GitHub Actions OIDC trust policy errors
IAM permission errors during Terraform plan/apply
ALB target group health check failures
S3 artifact bucket cleanup during destroy
Auto Scaling instance refresh conflicts
Dev/prod naming conflicts
YAML indentation errors in GitHub Actions workflows

These challenges helped improve practical troubleshooting skills across AWS, Terraform, IAM, networking, and CI/CD.

Final Outcome

This project demonstrates the ability to design, deploy, automate, monitor, and troubleshoot a production-style AWS environment using Terraform and GitHub Actions.

It shows hands-on experience with:

Cloud infrastructure design
Infrastructure as Code
Secure networking
CI/CD automation
Monitoring and alerting
Auto Scaling and self-healing
Dev/prod environment separation
