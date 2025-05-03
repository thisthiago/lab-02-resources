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

variable "infra_bucket" {
  type    = string
  default = "tfstate-lab-02-infra-us-east-1"
}


variable "studio_user_name" {
  description = "The IAM user or role ARN that will be used for EMR Studio session mapping"
  type        = string
  default     = "admin"
}

variable "bucket_names" {
  description = "Lista de nomes de buckets S3 a serem criados"
  type        = list(string)
  default     = ["landing", "bronze", "silver", "gold", "athena-results"]
}

variable "glue_tables" {
  type = map(map(map(list(string))))
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

locals {
  lambda_function_root_path = "/home/thiago/work/lab-02-resources/app/scripts/" #Alterar

  glue_crawler_role_arn = {
    dev = "arn:aws:iam::${var.aws_account_id}:role/dev-glue-crawler-role"
  }

  common_tags = {
    Environment = terraform.workspace
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}