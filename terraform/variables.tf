variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "streamingapp"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "eks_cluster_version" {
  description = "EKS cluster Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "eks_node_instance_types" {
  description = "EKS node instance types"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_desired_nodes" {
  description = "Desired number of EKS nodes"
  type        = number
  default     = 2
}

variable "eks_min_nodes" {
  description = "Minimum number of EKS nodes"
  type        = number
  default     = 1
}

variable "eks_max_nodes" {
  description = "Maximum number of EKS nodes"
  type        = number
  default     = 5
}

variable "jenkins_instance_type" {
  description = "Jenkins EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "jenkins_volume_size" {
  description = "Jenkins EBS volume size in GB"
  type        = number
  default     = 50
}

variable "enable_jenkins" {
  description = "Enable Jenkins EC2 instance"
  type        = bool
  default     = true
}

variable "enable_ecr_repositories" {
  description = "Enable ECR repositories"
  type        = bool
  default     = true
}

variable "sns_email_endpoint" {
  description = "Email endpoint for SNS notifications"
  type        = string
  default     = "devops@example.com"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
