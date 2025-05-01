variable "aws_region" {
  type    = string
  default = "us-east-2"
}

#alterar para o id da sua account
variable "aws_account_id" {
  type    = string
  default = "061043050175"
}

variable "project_name" {
  type    = string
  default = "lab-02"
}

variable "bucket_names" {
  description = "Lista de nomes de buckets S3 a serem criados"
  type        = list(string)
  default     = ["landing", "bronze", "silver", "gold", "athena-results"] 
}

variable "glue_tables" {
  type = map(map(map(list(string))))
}

locals {
  lambda_function_root_path  = "/home/thiago/aula-01/lab-02-resources/app/scripts/" #Alterar

  glue_crawler_role_arn = {
    dev  = "arn:aws:iam::${var.aws_account_id}:role/dev-glue-crawler-role"
  }

  common_tags = {
    Environment = terraform.workspace
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}