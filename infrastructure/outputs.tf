
output "cluster_id" {
    description = "cluster id"
    value = aws_ecs_cluster.cluster.id
}

output "repository_url" {
    description = "repository url"
    value = aws_ecr_repository.hello_repository.repository_url
}

output "task_definition" {
    description = "task definition arn"
    value = aws_ecs_task_definition.hello_definition.arn
}

output "vpc_id" {
    description = "vpc id"
    value = aws_default_vpc.vpc.id
}
output "subnets_ids" {
    description = "subnets ids"
    value = data.aws_subnet_ids.subnets.ids
}

output "lb_arn" {
    description = "elastic load balancer arn"
    value = aws_lb.lb.arn
}

output "lb_dns" {
    description = "elastic load balancer dns name"
    value = aws_lb.lb.dns_name
}