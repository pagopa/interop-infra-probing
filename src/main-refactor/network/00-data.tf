data "aws_eks_cluster" "probing" {
  count = var.eks_cluster_name != null ? 1 : 0

  name = var.eks_cluster_name
}