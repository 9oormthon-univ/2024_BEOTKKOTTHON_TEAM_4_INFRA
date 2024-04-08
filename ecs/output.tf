output "vacgom_cluster_name" {
    value = aws_ecs_cluster.vacgom-cluster-2.id
}

output "vacgom_capacity_provider_id" {
    value = aws_ecs_cluster_capacity_providers.vacgom-cluster-capacity-providers.capacity_providers
}

output "alb_id" {
    value = aws_alb.vacgom-alb-2.arn
}
