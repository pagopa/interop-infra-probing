resource "aws_lb" "nlb" {
  name               = "${var.app_name}-nlb-${var.env}"
  internal           = true
  load_balancer_type = "network"
  subnets            = data.aws_subnets.workload.ids

  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}

resource "aws_lb_target_group" "alb" {
  name        = "${var.app_name}-alb-tg-${var.env}"
  target_type = "alb"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "test" {
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
}


resource "aws_lb_listener" "alb_eks" {
  load_balancer_arn = aws_lb.alb_eks.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
  }
}