resource "aws_iam_role" "emr_studio_service_role" {
  name = "EMR_Studio_Service_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "elasticmapreduce.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "emr_studio_policy" {
  name   = "EMRStudioCustomPolicy"
  policy = file("${path.module}/policies/iam-emr-studio-policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_emr_studio_policy" {
  role       = aws_iam_role.emr_studio_service_role.name
  policy_arn = aws_iam_policy.emr_studio_policy.arn
}

resource "aws_emr_studio" "emr_studio" {
  name                        = "${terraform.workspace}-${var.project_name}-emr-studio"
  auth_mode                   = "IAM"
  vpc_id                      = aws_vpc.emr_vpc.id
  subnet_ids                  = [aws_subnet.emr_subnet.id]
  service_role                = aws_iam_role.emr_studio_service_role.arn
  workspace_security_group_id = aws_security_group.emr_sg.id
  engine_security_group_id    = aws_security_group.emr_sg.id
  default_s3_location         = "s3://${var.infra_bucket}/emr-studio-artifacts/"

  tags = local.common_tags
}

resource "aws_security_group" "emr_sg" {
  name        = "${terraform.workspace}-${var.project_name}-emr-studio-sg"
  description = "Security Group for EMR Studio"
  vpc_id      = aws_vpc.emr_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}
