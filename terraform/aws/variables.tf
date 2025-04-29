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

locals {
  cluster_name = "${var.project_name}-eks-${terraform.workspace}"

  spark_role_name      = "${var.project_name}-spark-role-${terraform.workspace}"
  
  map_roles = jsondecode(file("${path.module}/environments/${terraform.workspace}/eks_roles_map.json"))

  common_tags = {
    Environment = terraform.workspace
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}