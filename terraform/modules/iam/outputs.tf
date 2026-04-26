output "cluster_role_arn" { value = aws_iam_role.cluster.arn }
output "node_role_arn"    { value = aws_iam_role.node.arn }
output "pod_exec_role_arn" { value = aws_iam_role.pod_exec.arn }
