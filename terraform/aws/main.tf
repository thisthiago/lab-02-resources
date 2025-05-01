provider "aws" {
  region = var.aws_region # Usa a variável definida em variables.tf
}

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }

  backend "s3" {
    bucket = "tfstate-lab-02-infra-us-east-1"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}