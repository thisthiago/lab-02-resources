resource "aws_emrserverless_application" "delta_pyspark_app" {
  name          = "${terraform.workspace}-${var.project_name}-delta-pyspark"
  release_label = "emr-6.15.0"
  type          = "SPARK"

  auto_start_configuration {
    enabled = true
  }

  auto_stop_configuration {
    enabled              = true
    idle_timeout_minutes = 15
  }

  maximum_capacity {
    cpu    = "16 vCPU"
    memory = "64 GB"
    disk   = "200 GB"
  }

  initial_capacity {
    initial_capacity_type = "DRIVER"
    initial_capacity_config {
      worker_configuration {
        cpu    = "2 vCPU"
        memory = "8 GB"
        disk   = "20 GB"
      }
      worker_count = 1
    }
  }

  tags = local.common_tags
}

resource "aws_iam_role" "emr_serverless_runtime_role" {
  name = "${terraform.workspace}-${var.project_name}-emr-serverless-runtime-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "emr-serverless.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_policy" "emr_serverless_runtime_policy" {
  name        = "${terraform.workspace}-${var.project_name}-emr-serverless-runtime-policy"
  description = "Policy for EMR Serverless runtime role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "iam:PassRole"
        ],
        Resource = [
          "arn:aws:s3:::${var.infra_bucket}/*",
          "arn:aws:s3:::${var.infra_bucket}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "emr_serverless_runtime_policy_attachment" {
  role       = aws_iam_role.emr_serverless_runtime_role.name
  policy_arn = aws_iam_policy.emr_serverless_runtime_policy.arn
}

resource "aws_iam_policy" "emr_studio_user_policy" {
  name        = "${terraform.workspace}-${var.project_name}-emr-studio-user-policy"
  description = "Policy for EMR Studio users to access EMR Serverless"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticmapreduce:CreateStudioPresignedUrl",
          "elasticmapreduce:DescribeStudio",
          "elasticmapreduce:ListStudios",
          "emr-serverless:AccessInteractiveEndpoints",
          "emr-serverless:GetDashboardForJobRun",
          "emr-serverless:GetJobRun",
          "emr-serverless:ListJobRuns",
          "emr-serverless:StartJobRun",
          "emr-serverless:GetApplication",
          "emr-serverless:ListApplications",
          "emr-serverless:StartApplication",
          "emr-serverless:StopApplication",
          "emr-serverless:GetComputeConfiguration",
          "emr-serverless:ListComputeConfigurations",
          "emr-serverless:CreateComputeConfiguration",
          "emr-serverless:DeleteComputeConfiguration",
          "emr-serverless:UpdateComputeConfiguration",
          "iam:PassRole"
        ],
        Resource = [
          aws_iam_role.emr_serverless_runtime_role.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.infra_bucket}/*",
          "arn:aws:s3:::${var.infra_bucket}"
        ]
      }
    ]
  })
}

output "emr_serverless_application_id" {
  value       = aws_emrserverless_application.delta_pyspark_app.id
  description = "EMR Serverless Application ID for Delta and PySpark"
}

output "emr_studio_user_policy_arn" {
  value       = aws_iam_policy.emr_studio_user_policy.arn
  description = "ARN of the IAM policy for EMR Studio users"
}

output "emr_studio_id" {
  value = aws_emr_studio.emr_studio.id
  description = "The ID of the EMR Studio"
}

output "emr_serverless_runtime_role_arn" {
  value = aws_iam_role.emr_serverless_runtime_role.arn
  description = "ARN of the EMR Serverless runtime role"
}
