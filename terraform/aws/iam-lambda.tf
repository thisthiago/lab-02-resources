# IAM Role para a Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${terraform.workspace}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name   = "lambda-s3-access-policy"
  role   = aws_iam_role.lambda_role.id
  policy = file("${path.module}/policies/iam-policy-lambda-landing.json")
}

# Permissão básica para logs (obrigatória para Lambda)
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}