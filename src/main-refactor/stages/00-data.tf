data "aws_vpc" "probing" {
  id = var.vpc_id
}

data "aws_eks_cluster" "probing" {
  name = var.eks_cluster_name
}

data "aws_iam_openid_connect_provider" "probing_eks" {
  url = data.aws_eks_cluster.probing.identity[0].oidc[0].issuer
}

data "aws_rds_cluster" "probing_operational_database" {
  cluster_identifier = var.probing_operational_database_cluster_identifier
}

# data "aws_timestreamwrite_database" "probing_analytics_database" {
#   name = var.probing_analytics_database_name
# }

data "aws_subnets" "probing_int_lbs" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.probing.id]
  }

  filter {
    name   = "cidr-block"
    values = toset(var.int_lbs_cidrs)
  }
}

data "aws_route53_zone" "probing_base" {
  name         = var.probing_base_route53_zone_name
  private_zone = false
}

###

# data "aws_subnets" "analytics" {
#   filter {
#     name   = "subnet-id"
#     values = var.analytics_subnet_ids
#   }
# }

# data "aws_eks_cluster_auth" "core" {
#   name = var.eks_cluster_name
# }

# data "aws_iam_openid_connect_provider" "core_eks" {
#   url = data.aws_eks_cluster.core.identity[0].oidc[0].issuer
# }

# data "aws_security_group" "core_eks_cluster_node" {
#   id = var.eks_cluster_node_security_group_id
# }

# data "aws_dynamodb_table" "terraform_lock" {
#   name     = "terraform-lock"
#   provider = aws.ec1
# }

# data "aws_s3_bucket" "terraform_states" {
#   bucket   = format("terraform-backend-%s", data.aws_caller_identity.current.account_id)
#   provider = aws.ec1
# }

# data "aws_s3_bucket" "jwt_audit_source" {
#   bucket = var.jwt_details_bucket_name
# }

# data "aws_s3_bucket" "alb_logs_source" {
#   bucket = var.alb_logs_bucket_name
# }

# data "aws_iam_openid_connect_provider" "github" {
#   url = "https://token.actions.githubusercontent.com"
# }

# data "aws_iam_role" "github_runner_task" {
#   name = var.github_runner_task_role_name
# }

# data "aws_msk_cluster" "platform_events" {
#   cluster_name = var.msk_cluster_name
# }

# data "aws_iam_role" "application_audit_producers" {
#   for_each = toset(var.application_audit_producers_irsa_list)

#   name = each.value
# }
