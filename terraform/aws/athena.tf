resource "aws_athena_database" "bronze" {
  name   = "db_${terraform.workspace}_bronze"
  bucket = "${terraform.workspace}-${var.project_name}-${var.aws_region}-${var.bucket_names[4]}"
}

resource "aws_athena_database" "silver" {
  name   = "db_${terraform.workspace}_silver"
  bucket = "${terraform.workspace}-${var.project_name}-${var.aws_region}-${var.bucket_names[4]}"
}

resource "aws_athena_database" "gold" {
  name   = "db_${terraform.workspace}_gold"
  bucket = "${terraform.workspace}-${var.project_name}-${var.aws_region}-${var.bucket_names[4]}"
}

# Workgroup padrão configurado para usar o bucket existente
resource "aws_athena_workgroup" "lab02" {
  name = "dev-lab02-workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location =  "s3://${terraform.workspace}-${var.project_name}-${var.aws_region}-${var.bucket_names[4]}/output/"
    }
  }

  tags = local.common_tags
}