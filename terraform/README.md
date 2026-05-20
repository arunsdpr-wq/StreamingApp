# Terraform Setup Guide for StreamingApp

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0 installed
- AWS CLI v2 configured
- Git installed

## File Structure

```
terraform/
├── main.tf                    # Provider and terraform config
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── vpc.tf                      # VPC and networking
├── ecr.tf                      # ECR repositories
├── eks.tf                      # EKS cluster and node groups
├── iam.tf                      # IAM roles and policies
├── security_groups.tf          # Security groups
├── jenkins.tf                  # Jenkins EC2 instance
├── jenkins_bootstrap.sh        # Jenkins installation script
├── monitoring.tf               # CloudWatch and SNS
├── terraform.tfvars            # Dev environment values
├── terraform.prod.tfvars       # Prod environment values
├── BACKEND.md                  # Backend configuration guide
└── README.md                   # This file
```

## Quick Start

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Plan Deployment

**Dev Environment:**
```bash
terraform plan -var-file=terraform.tfvars -out=dev.plan
```

**Production Environment:**
```bash
terraform plan -var-file=terraform.prod.tfvars -out=prod.plan
```

### 3. Apply Configuration

**Dev Environment:**
```bash
terraform apply dev.plan
```

**Production Environment:**
```bash
terraform apply prod.plan
```

## Resource Overview

### 1. VPC & Networking
- VPC with CIDR 10.0.0.0/16
- 2 Public subnets (for Jenkins, NAT Gateway)
- 2 Private subnets (for EKS nodes)
- Internet Gateway
- NAT Gateway for private subnet egress
- Route tables and associations
- VPC Flow Logs (optional)

### 2. Amazon ECR
- 5 ECR repositories:
  - streamingapp-auth-service
  - streamingapp-streaming-service
  - streamingapp-admin-service
  - streamingapp-chat-service
  - streamingapp-frontend
- Image scanning on push enabled
- Lifecycle policies (keep last 10 images)

### 3. Amazon EKS
- EKS cluster v1.28+
- Node group with configurable instance types (default: t3.medium)
- Auto-scaling enabled
- EKS add-ons:
  - VPC CNI
  - CoreDNS
  - kube-proxy
- CloudWatch logging enabled

### 4. Jenkins EC2
- Ubuntu 22.04 LTS
- Instance type: t3.medium (configurable)
- 50GB gp3 EBS volume (configurable)
- Automatic installation of:
  - Java 17
  - Jenkins
  - Docker
  - Docker Compose
  - AWS CLI
  - kubectl
  - Helm
- Public IP address
- Elastic IP for stable IP

### 5. Security
- IAM roles for EKS cluster and nodes
- IAM role for Jenkins with:
  - ECR access
  - EKS access
  - S3 access for artifacts
  - CloudWatch Logs access
- Security groups for:
  - EKS cluster
  - EKS nodes
  - Jenkins
  - Application Load Balancer

### 6. Monitoring & Alerts
- CloudWatch log groups:
  - /aws/eks/streamingapp-cluster (EKS logs)
  - /aws/jenkins (Jenkins logs)
  - /aws/vpc/flowlogs/streamingapp (VPC Flow Logs)
- SNS topic for deployment alerts
- Email subscription for notifications
- CloudWatch alarms:
  - EKS node CPU > 80%
  - Jenkins CPU > 80%
  - Jenkins disk > 85%

## Configuration Variables

### Environment Variables (terraform.tfvars)

```hcl
environment              = "dev"              # Environment name
aws_region              = "ap-south-1"        # AWS region
project_name            = "streamingapp"      # Project name
vpc_cidr                = "10.0.0.0/16"       # VPC CIDR
enable_nat_gateway      = true                # Enable NAT Gateway
eks_cluster_version     = "1.28"              # Kubernetes version
eks_node_instance_types = ["t3.medium"]       # Node instance types
eks_desired_nodes       = 2                   # Desired nodes count
eks_min_nodes           = 1                   # Min nodes for auto-scaling
eks_max_nodes           = 5                   # Max nodes for auto-scaling
jenkins_instance_type   = "t3.medium"         # Jenkins instance type
jenkins_volume_size     = 50                  # Jenkins volume size (GB)
enable_jenkins          = true                # Enable Jenkins
enable_ecr_repositories = true                # Enable ECR repos
sns_email_endpoint      = "devops@example.com" # Email for alerts
```

## Common Commands

### Validate Configuration
```bash
terraform validate
```

### Format Configuration
```bash
terraform fmt -recursive
```

### View Plan
```bash
terraform plan -var-file=terraform.tfvars
```

### Destroy Resources
```bash
# Be careful with this command!
terraform destroy -var-file=terraform.tfvars
```

### Get Outputs
```bash
terraform output
```

### Refresh State
```bash
terraform refresh
```

## Accessing Resources

### Jenkins
After deployment, Jenkins will be accessible at:
```
http://<jenkins-public-ip>:8080
```

Get the public IP:
```bash
terraform output jenkins_public_ip
```

### EKS Cluster
Configure kubectl:
```bash
aws eks update-kubeconfig \
  --name streamingapp-cluster \
  --region ap-south-1
```

Or use the provided command:
```bash
terraform output kubeconfig_command
```

### ECR Repositories
Get repository URLs:
```bash
terraform output ecr_repository_urls
```

## Troubleshooting

### Terraform Init Fails
```bash
# Clear cached plugins
rm -rf .terraform
terraform init
```

### AWS Credentials Not Found
```bash
# Configure AWS CLI
aws configure
```

### EKS Cluster Not Accessible
```bash
# Verify EKS cluster
aws eks describe-cluster --name streamingapp-cluster

# Update kubeconfig
aws eks update-kubeconfig --name streamingapp-cluster

# Test access
kubectl get nodes
```

### Jenkins Bootstrap Failed
```bash
# SSH into Jenkins instance
ssh -i <key.pem> ubuntu@<jenkins-public-ip>

# Check installation logs
sudo tail -f /var/log/cloud-init-output.log
```

## Cost Optimization

- Use spot instances for non-production
- Scale down during off-hours
- Use smaller instance types for dev
- Clean up unused resources regularly

## Security Best Practices

- Restrict security group ingress rules
- Use IAM roles instead of keys
- Enable encryption for EBS and S3
- Rotate credentials regularly
- Use private subnets for EKS nodes
- Enable VPC Flow Logs for monitoring

## State Management

For production deployments, use S3 backend with DynamoDB locking:

1. Create S3 bucket and DynamoDB table (see BACKEND.md)
2. Uncomment backend configuration in main.tf
3. Run `terraform init` again

## Next Steps

1. Deploy infrastructure: `terraform apply -var-file=terraform.tfvars`
2. Configure Jenkins: Access http://<jenkins-ip>:8080
3. Deploy applications using Helm charts
4. Set up monitoring and alerting
5. Configure CI/CD pipelines in Jenkins

## Support

For issues or questions:
- Check Terraform documentation: https://www.terraform.io/docs
- AWS documentation: https://docs.aws.amazon.com
- EKS best practices: https://docs.aws.amazon.com/eks/latest/userguide/best-practices.html

## License

This Terraform configuration is part of the StreamingApp project.
