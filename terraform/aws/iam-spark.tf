# IAM Roles for Service Accounts (IRSA)
# see: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
resource "aws_iam_policy" "spark_policy" {
  name        = "${var.project_name}-eks-policy-spark-${terraform.workspace}"
  description = "Policy for spark eks"

  policy = file("${path.module}/policies/iam-policy-spark.json")
  tags   = local.common_tags
}

data "aws_iam_policy_document" "spark_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:processing:spark", "system:serviceaccount:notebook:notebook"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "web_identity_spark_role" {
  assume_role_policy = data.aws_iam_policy_document.spark_assume_role.json
  name               = local.spark_role_name
  tags               = local.common_tags
}

resource "aws_iam_policy_attachment" "spark_sa" {
  name       = "${var.project_name}-spark-role-${terraform.workspace}"
  roles      = [aws_iam_role.web_identity_spark_role.name]
  policy_arn = aws_iam_policy.spark_policy.arn
}