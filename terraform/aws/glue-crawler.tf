resource "aws_glue_catalog_database" "db_silver" {
  name = "db_${terraform.workspace}_silver"
  tags = local.common_tags
}

resource "aws_glue_crawler" "silver_crawlers_delta" {
  for_each      = toset(var.glue_tables[terraform.workspace]["silver_delta"]["tables"])
  database_name = aws_glue_catalog_database.db_silver.name
  name          = "${terraform.workspace}-silver-${replace(each.key, "_", "-")}-crawler"
  role          = local.glue_crawler_role_arn[terraform.workspace]
  table_prefix  = "sz_"
  delta_target {
    delta_tables              = ["s3://${terraform.workspace}-${var.project_name}-${var.aws_region}-silver/${each.key}/"]
    create_native_delta_table = "true"
    write_manifest            = "false"
  }
  tags = local.common_tags
}

resource "aws_glue_crawler" "silver_crawlers_parquet" {
  for_each      = toset(var.glue_tables[terraform.workspace]["silver_parquet"]["tables"])
  database_name = aws_glue_catalog_database.db_silver.name
  name          = "${terraform.workspace}-silver-${replace(each.key, "_", "-")}-crawler"
  role          = local.glue_crawler_role_arn[terraform.workspace]
  table_prefix  = "sz_"
  s3_target {
    path = "s3://${terraform.workspace}-${var.project_name}-${var.aws_region}-silver/${each.key}/"
  }
  tags = local.common_tags
}