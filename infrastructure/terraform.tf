
resource "aws_default_vpc" "vpc" {
    enable_dns_hostnames = true
    enable_dns_support = true
}

data "aws_subnet_ids" "subnets" {
    vpc_id = aws_default_vpc.vpc.id
}

resource "aws_lb" "lb" {
    name = "hello-lb"
    internal = false  
    load_balancer_type = "application"
    subnets = data.aws_subnet_ids.subnets.ids
    enable_deletion_protection = false
    security_groups = [
        aws_security_group.lb_sg.id
    ]
}

resource "aws_lb_listener" "lb_hello_listener" {
    load_balancer_arn = aws_lb.lb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.hello_tg.id
    }
}

resource "aws_ecs_cluster" "cluster" {
  name = "cluster"
  capacity_providers= ["FARGATE"]

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecr_repository" "hello_repository" {
  name                 = "hello"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

data "aws_iam_policy_document" "assume_role" {
    statement {
        actions = ["sts:AssumeRole"]
        effect = "Allow"

        principals {
            type = "Service"
            identifiers = [
               "ecs.amazonaws.com",
               "ecs-tasks.amazonaws.com",
            ]
        }
    }
}

locals {
    container_port = 8080
    container_name = "hello"
}

data "aws_iam_policy_document" "ecs_role_inline_policy" {
    statement {
        actions = ["ecs:*"]
        effect = "Allow"
        resources = [
            "*"
        ]
    }
    statement {
        actions = ["ecr:*"]
        effect = "Allow"
        resources = [
            "*"
        ]
    }
}


resource "aws_iam_role" "ecs_role" {
    name = "ecs_role"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json

    inline_policy {
        name = "ecs_role_inline_policy"
        policy = data.aws_iam_policy_document.ecs_role_inline_policy.json
    }
}


resource "aws_ecs_task_definition" "hello_definition" {
    family = format("%s-definition", local.container_name)
    cpu = 256
    memory = 512
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn = aws_iam_role.ecs_role.arn
    task_role_arn = aws_iam_role.ecs_role.arn
    
    container_definitions = jsonencode([
        {
            name = local.container_name
            image = var.registry
            cpu = 256
            memory = 512
            portMappings = [
                {
                    containerPort = local.container_port
                    hostPort = local.container_port
                }
            ]

        }
    ])
}
resource "aws_lb_target_group" "hello_tg" {
    name = format("%s-tg", local.container_name)
    port = 80
    protocol= "HTTP"
    vpc_id = aws_default_vpc.vpc.id
    target_type = "ip"

    health_check {
        enabled = true
        path = "/hello/world"
    }
}

resource "aws_security_group" "hello_sg" {
    name = format("%s-sg", local.container_name)
    vpc_id = aws_default_vpc.vpc.id

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "lb_sg" {
    name = "lb-sg"
    vpc_id = aws_default_vpc.vpc.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_ecs_service" "hello_service" {
    name = format("%s-service", local.container_name)
    cluster = aws_ecs_cluster.cluster.id
    task_definition = aws_ecs_task_definition.hello_definition.arn
    desired_count = 1
    launch_type = "FARGATE"
    wait_for_steady_state = false

    load_balancer {
        target_group_arn = aws_lb_target_group.hello_tg.id
        container_port = local.container_port
        container_name = local.container_name
    }

    network_configuration {
        subnets = data.aws_subnet_ids.subnets.ids
        assign_public_ip = true
        security_groups = [
            aws_security_group.hello_sg.id
        ]
    }

    depends_on = [
        aws_lb_listener.lb_hello_listener
    ]
}
