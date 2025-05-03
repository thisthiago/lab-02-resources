resource "aws_iam_policy" "glue_studio_policy" {
  name        = "AWSGlueStudioCustomPolicy"
  description = "Custom policy for Glue Studio access"
  tags        = local.common_tags
  policy      = file("${path.module}/policies/iam-policy-glue-studio.json")
}

resource "aws_iam_role_policy_attachment" "glue_studio_attachment" {
  role       = aws_iam_role.glue_studio_role.name
  policy_arn = aws_iam_policy.glue_studio_policy.arn
}

resource "aws_iam_role" "glue_studio_role" {
  name = "AWSGlueStudioRole"
  tags = local.common_tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "${var.aws_account_id}",
            "aws:SourceArn"     = "arn:aws:glue:us-east-1:${var.aws_account_id}:*"
          }
        }
      }
    ]
  })
}