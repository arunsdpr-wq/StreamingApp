data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EKS Cluster Addon data
data "aws_eks_addon_version" "vpc_cni" {
  addon_name             = "vpc-cni"
  kubernetes_version     = var.eks_cluster_version
  most_recent            = true
}

data "aws_eks_addon_version" "coredns" {
  addon_name             = "coredns"
  kubernetes_version     = var.eks_cluster_version
  most_recent            = true
}

data "aws_eks_addon_version" "kube_proxy" {
  addon_name             = "kube-proxy"
  kubernetes_version     = var.eks_cluster_version
  most_recent            = true
}
