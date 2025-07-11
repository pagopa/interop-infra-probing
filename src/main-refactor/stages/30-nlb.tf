resource "aws_api_gateway_vpc_link" "integration" {
  name        = format("interop-backend-integration-%s", var.stage)
  description = "VPC Link to privately connect REST APIGW to NLB"
  target_arns = [module.nlb.lb_arn]
}

module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"

  name = format("be-integration-nlb-%s", var.stage)

  load_balancer_type = "network"
  internal           = true
  vpc_id             = data.aws_vpc.probing.id
  subnets            = data.aws_subnets.probing_int_lbs.ids

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = 443
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name             = format("be-integration-alb-tg-%s", var.stage)
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "alb"
      targets = {
        probing_alb = {
          target_id = aws_lb.probing.arn
          port      = 80
        }
      }
      connection_termination = false
      preserve_client_ip     = true
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        matcher             = "200-499"
      }
    }
  ]
}
