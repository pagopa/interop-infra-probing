data "aws_iam_policy" "task_exec" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_tasks_assume_condition" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [format("arn:aws:ecs:%s:%s:*", var.aws_region, data.aws_caller_identity.current.account_id)]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "github_runner_task_exec" {
  name = format("%s-github-runner-ecs-task-exec-%s", local.project, var.env)

  assume_role_policy  = data.aws_iam_policy_document.ecs_tasks_assume.json
  managed_policy_arns = toset([data.aws_iam_policy.task_exec.arn])

  inline_policy {
    name = "CreateLogGroup"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "logs:CreateLogGroup"
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "github_runner_task" {
  name = format("%s-github-runner-task-%s", local.project, var.env)

  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_condition.json

  inline_policy {
    name = "KubeConfigPolicy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "eks:DescribeCluster"
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name = "ReadImagesPolicy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchGetImage"
          ]
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name = "AssumeRolePolicy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sts:AssumeRole",
            "sts:TagSession"
          ]
          # String interpolation is necessary otherwise referencing the deployment role resource would cause a dependency cicle 
          Resource = format("arn:aws:iam::%s:role/%s", data.aws_caller_identity.current.account_id, local.deployment_github_repo_iam_role_name)
        }
      ]
    })
  }
}

resource "aws_ecs_cluster" "github_runners" {
  name = format("%s-github-runners-%s", local.project, var.env)

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.github_runners.name

  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_task_definition" "github_runner" {
  family = format("%s-github-runner-%s", local.project, var.env)

  cpu                = var.github_runners_cpu
  memory             = var.github_runners_memory
  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.github_runner_task_exec.arn
  task_role_arn      = aws_iam_role.github_runner_task.arn

  container_definitions = jsonencode([
    {
      name      = "github-runner"
      cpu       = var.github_runners_cpu
      memory    = var.github_runners_memory
      essential = true
      image     = var.github_runners_image_uri

      portMappngs = [
        {
          containerPort = 443
          hostPort      = 443
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.aws_region
          awslogs-group         = "/aws/ecs"
          awslogs-stream-prefix = "github-runners"
          awslogs-create-group  = "true"
        }
      }
    }
  ])
}

resource "aws_security_group" "github_runners" {
  name        = format("ecs/%s-github-runners-%s", local.project, var.env)
  description = "SG for Github runners"

  vpc_id = data.aws_vpc.probing.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
