resource "aws_security_group" "probing_alb" {
  name        = format("elb/%s-alb-%s", local.project, var.stage)
  description = "Security group for Probing ALB"

  vpc_id = data.aws_vpc.probing.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "probing" {
  name = format("%s-alb-%s", local.project, var.stage)

  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.probing_alb.id]
  subnets            = data.aws_subnets.probing_int_lbs.ids
  ip_address_type    = "ipv4"

  preserve_host_header = true

  access_logs {
    bucket  = module.alb_logs_bucket.s3_bucket_id
    enabled = true
  }
}

resource "aws_lb_listener" "probing_80" {
  load_balancer_arn = aws_lb.probing.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      status_code  = "404"
    }
  }
}

resource "aws_lb_target_group" "api" {
  name            = format("%s-api", var.stage)
  port            = var.backend_microservices_port
  protocol        = "HTTP"
  target_type     = "ip"
  ip_address_type = "ipv4"
  vpc_id          = data.aws_vpc.probing.id

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  health_check {
    enabled             = true
    interval            = 15
    path                = "/status"
    port                = var.backend_microservices_port
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_lb_target_group" "statistics_api" {
  name            = format("%s-statistics-api", var.stage)
  port            = var.backend_microservices_port
  protocol        = "HTTP"
  target_type     = "ip"
  ip_address_type = "ipv4"
  vpc_id          = data.aws_vpc.probing.id

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  health_check {
    enabled             = true
    interval            = 15
    path                = "/status"
    port                = var.backend_microservices_port
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_lb_listener_rule" "statistics_api" {
  listener_arn = aws_lb_listener.probing_80.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.statistics_api.arn
  }

  condition {
    path_pattern {
      values = ["/telemetryData", "/telemetryData/*"]
    }
  }

  condition {
    host_header {
      values = [var.stage == "prod" ? "stato-eservice.interop.pagopa.it" : format("*.%s.stato-eservice.interop.pagopa.it", var.stage)]
    }
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.probing_80.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  condition {
    host_header {
      values = [var.stage == "prod" ? format("stato-eservice.interop.pagopa.it") : format("*.%s.stato-eservice.interop.pagopa.it", var.stage)]
    }
  }
}

resource "aws_vpc_security_group_ingress_rule" "from_alb" {
  security_group_id = data.aws_eks_cluster.probing.vpc_config[0].cluster_security_group_id

  from_port                    = 80
  to_port                      = var.backend_microservices_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.probing_alb.id
}
