data "aws_eks_cluster" "probing" {
  name = var.eks_cluster_name
}