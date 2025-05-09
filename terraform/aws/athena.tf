resource "aws_athena_workgroup" "lab02" {
  name = "${terraform.workspace}-${var.project_name}-workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${terraform.workspace}-${var.project_name}-${var.aws_region}-${var.bucket_names[4]}/output/"
    }
  }

  tags = local.common_tags
}