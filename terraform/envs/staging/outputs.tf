output "cluster_name" {
  description = "EKS cluster name – use in aws eks update-kubeconfig"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "pod_exec_role_arn" {
  description = "Annotate flask-app ServiceAccount with this ARN for IRSA"
  value       = module.iam.pod_exec_role_arn
}

output "cloudwatch_dashboard" {
  value = module.cloudwatch.dashboard_name
}

output "kubectl_config_command" {
  description = "Run this command after terraform apply to configure kubectl"
  value       = "aws eks update-kubeconfig --region ca-west-1 --name ${module.eks.cluster_name}"
}
