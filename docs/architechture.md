# AWS 3-Tier Architecture with Terraform & CI/CD

## Project Overview

This project demonstrates a production-style AWS 3-tier architecture built using Terraform and GitHub Actions CI/CD.

The infrastructure follows Infrastructure as Code best practices with modular Terraform design, environment separation, automated deployments, monitoring, and secure networking.

---

# High-Level Architecture

Users access the application through Route 53 custom domains.

Traffic flows through an Application Load Balancer using HTTPS with ACM certificates.

The ALB uses host-based routing to direct traffic to different applications.

The EC2 application servers run inside private subnets behind Auto Scaling Groups.

AWS Systems Manager Session Manager is used for secure private EC2 access instead of SSH or bastion hosts.

---

# Request Flow

```text
User
  ↓
Route 53 DNS
  ↓
Application Load Balancer HTTPS via ACM
  ↓
AWS WAF
  ↓
Target Groups
  ↓
Auto Scaling Groups
  ↓
Private EC2 Instances
```

---

# 3-Tier VPC Design

## Public Tier

Contains internet-facing resources.

### Components
- Application Load Balancer
- Internet Gateway
- Public Subnets

---

## Private Application Tier

Contains application servers.

### Components
- EC2 Instances
- Auto Scaling Groups
- Launch Templates
- Security Groups
- Systems Manager Session Manager

---

## Database Tier

Contains isolated database networking resources.

### Components
- Database Subnets
- RDS-ready subnet groups
- Restricted Security Groups

---

# Host-Based Routing

The Application Load Balancer uses host-based routing.

```text
app1.mbodou.org → App1 Target Group
app2.mbodou.org → App2 Target Group
mbodou.org      → Default Rule
```

### Benefits
- Multiple applications behind one ALB
- Reduced infrastructure cost
- Layer 7 routing demonstration
- Cleaner architecture design

---

# Auto Scaling & Self-Healing

Each application runs behind its own Auto Scaling Group.

### Features
- High Availability
- Self-Healing
- Rolling Deployments
- Automatic Instance Replacement

If an instance becomes unhealthy, Auto Scaling automatically replaces it.

---

# Secure Access with SSM

The EC2 instances are deployed in private subnets without public IP addresses.

AWS Systems Manager Session Manager is used instead of SSH.

### Benefits
- No inbound SSH ports
- No bastion host required
- More secure production access
- Simplified administration

---

# Terraform Modular Structure

The infrastructure is organized using reusable Terraform modules.

## Modules

```text
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
```

## Environments

```text
environments/
├── dev
└── prod
```

### Benefits
- Reusability
- Scalability
- Maintainability
- Environment Separation
- Production Readiness

---

# Remote Terraform State

Terraform state is stored remotely using Amazon S3.

DynamoDB is used for state locking.

```text
Terraform
  ↓
S3 Backend
  ↓
DynamoDB Lock Table
```

### Benefits
- Centralized state management
- Team collaboration
- State locking protection
- CI/CD integration

---

# CI/CD Infrastructure Pipeline

## Development Pipeline

```text
Code Change
  ↓
GitHub Push
  ↓
GitHub Actions
  ↓
Terraform fmt
  ↓
Terraform validate
  ↓
Terraform plan/apply
  ↓
AWS Infrastructure Updated
```

---

## Production Pipeline

```text
Manual Workflow Trigger
  ↓
GitHub Environment Approval
  ↓
Terraform plan/apply
  ↓
Production Infrastructure Updated
```

---

# Application Deployment Pipeline

Application deployments are separated from infrastructure deployments.

```text
App Code Change
  ↓
GitHub Actions
  ↓
Build ZIP Artifact
  ↓
Upload to S3
  ↓
Auto Scaling Instance Refresh
  ↓
New EC2 Instances Deploy Application
```

---

# Artifact Deployment

Artifacts are stored inside Amazon S3.

```text
s3://artifact-bucket/
├── app1/app1.zip
└── app2/app2.zip
```

During instance bootstrap:

```text
EC2 User Data
  ↓
Download ZIP from S3
  ↓
Extract to /var/www/html
  ↓
Start Apache
  ↓
ALB Health Check Passes
```

---

# Monitoring & Alerting

CloudWatch is used for monitoring and alerting.

### Monitoring Includes
- ALB Metrics
- Auto Scaling Metrics
- Target Group Health
- EC2 Metrics
- WAF Metrics

### Alerting

```text
CloudWatch Alarm
  ↓
SNS Notification
  ↓
Email Alert
```

---

# Security Features

### Implemented Security Controls
- Private EC2 Instances
- Security Groups
- No Public SSH Access
- Systems Manager Session Manager
- IAM Roles
- OIDC Authentication
- HTTPS with ACM
- AWS WAF Protection
- Terraform State Locking

---

# Dev & Prod Environment Separation

The project separates development and production environments.

```text
dev  → automatic deployment/testing
prod → manual approval deployment
```

This demonstrates production-style CI/CD separation.

---

# AWS Services Used

- VPC
- EC2
- Auto Scaling Groups
- Launch Templates
- Application Load Balancer
- Route 53
- ACM
- IAM
- S3
- DynamoDB
- Systems Manager
- CloudWatch
- SNS
- AWS WAF
- RDS

---

# Challenges Solved

During this project, several real-world engineering issues were solved:

- Terraform backend configuration issues
- S3 state checksum mismatch
- DynamoDB locking errors
- IAM OIDC trust policy troubleshooting
- ALB health check failures
- GitHub Actions YAML issues
- Auto Scaling instance refresh conflicts
- S3 artifact deployment troubleshooting
- Dev/prod naming conflicts

---

# Final Outcome

This project demonstrates hands-on experience with:

- AWS Cloud Infrastructure
- Infrastructure as Code
- Terraform Modular Design
- Remote State Management
- CI/CD Automation
- Monitoring & Alerting
- Auto Scaling & Self-Healing
- Secure Cloud Networking
- Production-Style AWS Architecture
