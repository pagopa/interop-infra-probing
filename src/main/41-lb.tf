resource "aws_lb" "nlb" {
  name               = "${var.app_name}-nlb-${var.env}"
  internal           = true
  load_balancer_type = "network"
  subnets            = data.aws_subnets.workload.ids

  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = true
}


resource "aws_lb_target_group" "alb" {
  name        = "${var.app_name}-alb-tg-${var.env}"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"


  health_check {
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200-499"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  vpc_id = module.vpc.vpc_id
}
resource "aws_lb_listener" "nlb_to_alb" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}

resource "aws_lb_listener_rule" "nlb_to_alb" {
  listener_arn = aws_lb_listener.nlb_to_alb.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}



resource "aws_lb_target_group_attachment" "alb" {
  target_group_arn = aws_lb_target_group.alb.arn
  target_id        = aws_lb.alb_eks.id
  port             = 80
}

resource "aws_lb" "alb_eks" {
  name               = "${var.app_name}-alb-${var.env}"
  internal           = true
  load_balancer_type = "application"
  subnets            = data.aws_subnets.workload.ids

  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = true
  tags = {
    "elbv2.k8s.aws/cluster"    = module.eks.cluster_name
    "ingress.k8s.aws/resource" = "LoadBalancer"
    "ingress.k8s.aws/stack"    = var.alb_ingress_group
  }
}