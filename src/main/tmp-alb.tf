resource "aws_lb" "alb_eks" {
  name               = "${var.app_name}-alb-${var.env}"
  internal           = true
  load_balancer_type = "application"
  subnets            = data.aws_subnets.workload.ids

  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = true
}


resource "aws_lb_listener" "alb_eks" {
  load_balancer_arn = aws_lb.alb_eks.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
  }

  tags = {
    "elbv2.k8s.aws/cluster"    = "interop-probing-eks-dev"
    "ingress.k8s.aws/resource" = "LoadBalancer"
    "ingress.k8s.aws/stack"    = "interop-probing-alb"
  }
}