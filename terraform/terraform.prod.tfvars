environment = "prod"
aws_region  = "ap-south-1"
project_name = "streamingapp"

vpc_cidr              = "10.0.0.0/16"
enable_nat_gateway    = true
eks_cluster_version   = "1.28"
eks_node_instance_types = ["t3.large"]
eks_desired_nodes     = 3
eks_min_nodes         = 2
eks_max_nodes         = 10

jenkins_instance_type = "t3.large"
jenkins_volume_size   = 100
enable_jenkins        = true

enable_ecr_repositories = true
sns_email_endpoint      = "devops@example.com"
