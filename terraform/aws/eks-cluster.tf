module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = local.cluster_name
  cluster_version = "1.28"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Add-ons essenciais
  cluster_addons = {
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
      configuration_values = jsonencode({
        env = {
          ENABLE_POD_ENI = "true"
        }
      })
    }
    aws-ebs-csi-driver = {
      resolve_conflicts_on_create = "OVERWRITE"
      service_account_role_arn    = module.ebs_csi_driver_irsa.iam_role_arn
      most_recent                 = true
    }
  }

  # Node Group padrão
  eks_managed_node_groups = {
    default = {
      name           = "${local.cluster_name}-ng"
      instance_types = ["t2.micro"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2

      # Security Group customizada (opcional)
      vpc_security_group_ids = [aws_security_group.eks_nodes.id]
    }
  }

  manage_aws_auth_configmap = true
  aws_auth_roles = local.map_roles

  tags = local.common_tags
}

# Security Group para os nodes (exemplo)
resource "aws_security_group" "eks_nodes" {
  name_prefix = "${local.cluster_name}-nodes"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}