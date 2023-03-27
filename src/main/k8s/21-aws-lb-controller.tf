
resource "helm_release" "aws_load_baalcer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "eks/aws-load-balancer-controller"
  version    = "2.4.7"
  namespace  = "kube-system"

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = data.aws_eks_cluster.this.vpc_config.vpc_id
  }


  set {
    name  = "clusterName"
    value = data.aws_eks_cluster.this.name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"

  }
}