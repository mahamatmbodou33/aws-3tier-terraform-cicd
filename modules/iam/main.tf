data "aws_caller_identity" "current" {}
resource "aws_iam_role" "github_actions_role" {
  name = "${var.project_name}-${var.environment}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = local.github_oidc_provider_arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:mahamatmbodou33/aws-3tier-terraform-cicd:*",
              "repo:mahamatmbodou33/aws-3tier-terraform-cicd:environment:dev"
            ]
          }
        }
      }
    ]
  })
}
resource "aws_iam_role" "ec2_app_role" {
  name = "${var.project_name}-${var.environment}-ec2-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "ec2_artifact_policy" {
  name = "${var.project_name}-${var.environment}-ec2-artifact-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.artifact_bucket_arn,
          "${var.artifact_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_attach_artifact" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = aws_iam_policy.ec2_artifact_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_app_profile" {
  name = "${var.project_name}-${var.environment}-ec2-app-profile"
  role = aws_iam_role.ec2_app_role.name
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

data "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 0 : 1

  url = "https://token.actions.githubusercontent.com"
}

locals {
  github_oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn

  iam_role_arn_prefix             = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-${var.environment}-*"
  iam_policy_arn_prefix           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.project_name}-${var.environment}-*"
  iam_instance_profile_arn_prefix = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/${var.project_name}-${var.environment}-*"
  rds_arn_prefix                  = "arn:aws:rds:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*:${var.project_name}-${var.environment}-*"
  sns_arn_prefix                  = "arn:aws:sns:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.project_name}-${var.environment}-*"
  dynamodb_lock_table_arn         = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.tf_lock_table_name}"
  tf_state_bucket_arn             = "arn:aws:s3:::${var.tf_state_bucket_name}"
}


resource "aws_iam_policy" "github_actions_policy" {
  name = "${var.project_name}-${var.environment}-github-actions-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # EC2 networking/compute, the ALB, Auto Scaling, DNS, ACM, WAF and
        # CloudWatch/Logs are left as Resource "*" on purpose: most of their
        # write and Describe/List actions don't support resource-level ARNs
        # at all, so restricting Resource here would either be a no-op or
        # break Terraform's normal plan/apply calls. Scoping these further
        # needs tag-based (ABAC) conditions - a good next step beyond this.
        Sid    = "BroadInfraServicesWithoutUsefulResourceScoping"
        Effect = "Allow"
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "route53:*",
          "acm:*",
          "wafv2:*",
          "cloudwatch:*",
          "logs:*"
        ]
        Resource = "*"
      },
      {
        Sid      = "IamScopedToThisProjectsResources"
        Effect   = "Allow"
        Action   = "iam:*"
        Resource = [
          local.iam_role_arn_prefix,
          local.iam_policy_arn_prefix,
          local.iam_instance_profile_arn_prefix
        ]
      },
      {
        Sid    = "IamReadOnlyAndAccountLevelActions"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetInstanceProfile",
          "iam:ListRoles",
          "iam:ListPolicies",
          "iam:ListOpenIDConnectProviders",
          "iam:GetOpenIDConnectProvider",
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
      },
      {
        Sid      = "PassOnlyThisProjectsEc2Role"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = local.iam_role_arn_prefix
      },
      {
        Sid    = "S3ScopedToStateAndArtifactBuckets"
        Effect = "Allow"
        Action = "s3:*"
        Resource = [
          local.tf_state_bucket_arn,
          "${local.tf_state_bucket_arn}/*",
          var.artifact_bucket_arn,
          "${var.artifact_bucket_arn}/*"
        ]
      },
      {
        Sid      = "DynamoDbScopedToLockTable"
        Effect   = "Allow"
        Action   = "dynamodb:*"
        Resource = local.dynamodb_lock_table_arn
      },
      {
        Sid      = "RdsScopedToThisProject"
        Effect   = "Allow"
        Action   = "rds:*"
        Resource = local.rds_arn_prefix
      },
      {
        Sid      = "SnsScopedToThisProject"
        Effect   = "Allow"
        Action   = "sns:*"
        Resource = local.sns_arn_prefix
      },
      {
        # ECR permissions for Docker pipeline
        Sid    = "EcrForDockerPipeline"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

resource "aws_iam_policy" "ec2_ecr_pull_policy" {
  name = "${var.project_name}-${var.environment}-ec2-ecr-pull-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_attach_ecr_pull" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = aws_iam_policy.ec2_ecr_pull_policy.arn
}
resource "aws_iam_policy" "ec2_prometheus_discovery_policy" {
  name = "${var.project_name}-${var.environment}-ec2-prometheus-discovery-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeAvailabilityZones"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_attach_prometheus_discovery" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = aws_iam_policy.ec2_prometheus_discovery_policy.arn
}