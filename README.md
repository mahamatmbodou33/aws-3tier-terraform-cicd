# Production-Style AWS 3-Tier Architecture with Terraform & CI/CD

## Project Overview

This project demonstrates a production-style AWS 3-tier architecture built using Terraform and GitHub Actions CI/CD.

The infrastructure follows Infrastructure as Code best practices with modular Terraform design, environment separation, automated deployments, monitoring, and secure networking.

---

# Architecture Features

- Modular Terraform architecture
- Dev and Prod environments
- Remote Terraform state using S3 + DynamoDB
- GitHub Actions CI/CD pipelines
- OIDC authentication for secure AWS access
- HTTPS using ACM + Route 53
- Application Load Balancer with host-based routing
- Auto Scaling Groups with Launch Templates
- AWS Systems Manager Session Manager access
- CloudWatch monitoring and alarms
- SNS alert notifications
- AWS WAF protection
- Automated S3 artifact deployments

---

# Architecture Diagram

<img width="1596" height="752" alt="Screenshot 2026-04-09 003542" src="https://github.com/user-attachments/assets/041e0f74-fa8c-45f9-b03c-e713453b8073" />


# High-Level Architecture

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

# 3-Tier Architecture Design

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

The ALB uses host-based routing.

```text
app1.mbodou.org → App1 Target Group
app2.mbodou.org → App2 Target Group
mbodou.org      → Default Rule
```

---

# Terraform Modular Structure

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

---

## Environments

```text
environments/
├── dev
└── prod
```

---

# Remote Terraform State

Terraform state is stored remotely using:

- Amazon S3 backend
- DynamoDB state locking

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
- Safe CI/CD deployments

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

During EC2 bootstrap:

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

### Alerting Flow

```text
CloudWatch Alarm
  ↓
SNS Notification
  ↓
Email Alert
```

---

# Security Features

- Private EC2 Instances
- No public SSH access
- AWS Systems Manager Session Manager
- Security Groups
- IAM Roles
- GitHub Actions OIDC Authentication
- HTTPS using ACM
- AWS WAF Protection
- Terraform State Locking

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

# Demo Video

Add your LinkedIn or YouTube demo link here.

```text
[https://linkedin.com/](https://youtu.be/a3lh6fcN9O8)
```

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
