# VPC
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

# Subnets
output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

# Security Groups
output "jenkins_security_group_id" {
  description = "Jenkins security group ID"
  value       = try(aws_security_group.jenkins[0].id, "")
}

output "eks_security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_security_group.eks_cluster.id
}

# ECR Repositories
output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value = {
    auth_service      = try(aws_ecr_repository.auth[0].repository_url, "")
    streaming_service = try(aws_ecr_repository.streaming[0].repository_url, "")
    admin_service     = try(aws_ecr_repository.admin[0].repository_url, "")
    chat_service      = try(aws_ecr_repository.chat[0].repository_url, "")
    frontend          = try(aws_ecr_repository.frontend[0].repository_url, "")
  }
}

# Jenkins
output "jenkins_instance_id" {
  description = "Jenkins EC2 instance ID"
  value       = try(aws_instance.jenkins[0].id, "")
}

output "jenkins_public_ip" {
  description = "Jenkins public IP address"
  value       = try(aws_instance.jenkins[0].public_ip, "")
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = try("http://${aws_instance.jenkins[0].public_ip}:8080", "")
}

# EKS
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "eks_cluster_iam_role_arn" {
  description = "EKS cluster IAM role ARN"
  value       = aws_eks_cluster.main.role_arn
}

output "eks_cluster_certificate_authority" {
  description = "EKS cluster certificate authority"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

# Node Group
output "eks_node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.main.id
}

output "eks_node_group_status" {
  description = "EKS node group status"
  value       = aws_eks_node_group.main.status
}

# IAM Roles
output "jenkins_iam_role_arn" {
  description = "Jenkins IAM role ARN"
  value       = try(aws_iam_role.jenkins[0].arn, "")
}

output "eks_node_iam_role_arn" {
  description = "EKS node IAM role ARN"
  value       = aws_iam_role.eks_node.arn
}

# SNS
output "sns_topic_arn" {
  description = "SNS topic ARN for notifications"
  value       = aws_sns_topic.deployments.arn
}

# CloudWatch
output "cloudwatch_log_group" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.eks.name
}

# Account ID
output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

# Kubeconfig
output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.aws_region}"
}
