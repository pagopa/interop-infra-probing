module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.10.0"

  cluster_name    = "${var.app_name}-eks-${var.env}"
  cluster_version = var.kubernetes_version

  cluster_addons = {
    kube-proxy = {
      addon_version = var.kubernetes_addons_versions.kube-proxy
    }
    vpc-cni = {
      addon_version = var.kubernetes_addons_versions.vpc-cni
    }
    coredns = {
      addon_version = var.kubernetes_addons_versions.coredns

      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = [module.vpc.private_subnets[3], module.vpc.private_subnets[4], module.vpc.private_subnets[5]]
  control_plane_subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = true
  create_node_security_group    = false

  fargate_profiles = merge(
    {
      default = {
        name = var.app_name
        selectors = [
          {
            namespace = var.app_name
          }
        ]

        timeouts = {
          create = "20m"
          delete = "20m"
        }
      }
    }
  )
}