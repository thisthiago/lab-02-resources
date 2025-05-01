resource "aws_s3_bucket" "this" {
  for_each      = toset(var.bucket_names)
  bucket        = "${terraform.workspace}-${var.project_name}-${var.aws_region}-${each.key}"
  tags          = local.common_tags
  force_destroy = false
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = toset(var.bucket_names)
  bucket   = "${terraform.workspace}-${var.project_name}-${var.aws_region}-${each.key}"

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  depends_on = [
    aws_s3_bucket.this
  ]
}