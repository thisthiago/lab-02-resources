# Configuração do provedor AWS
provider "aws" {
  region = var.aws_region # Usa a variável definida em variables.tf

  # Opcional: Perfil do AWS CLI (se não usar credenciais padrão)
  # profile = "meu-perfil-aws"

  # Opcional: Assume Role (se necessário)
  # assume_role {
  #   role_arn = "arn:aws:iam::123456789012:role/terraform-role"
  # }
}

data "aws_eks_cluster" "default" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

# Versão do Terraform (opcional, mas recomendado)
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }

  # Backend para armazenar o state 
  backend "s3" {
    bucket = "tfstate-lab-02-infra-us-east-1"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}