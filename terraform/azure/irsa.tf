## irsa.tf
#module "ebs_csi_driver_irsa" {
#  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#  version = "~> 5.0"
#
#  role_name = "${local.cluster_name}-ebs-csi-driver"
#
#  attach_ebs_csi_policy = true # Anexa a política AWS EBS CSI Driver
#
#  oidc_providers = {
#    main = {
#      provider_arn               = module.eks.oidc_provider_arn
#      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
#    }
#  }
#
#  tags = local.common_tags
#}