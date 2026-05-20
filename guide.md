End-to-End DevOps Guide — MERN StreamingApp on AWS EKS with Jenkins CI/CD

You’ll build a production-style DevOps pipeline for the MERN app using:

GitHub
Docker
Amazon ECR
Jenkins
Kubernetes (EKS)
Helm
CloudWatch
SNS + Slack/Telegram (Bonus)

Project Repository: StreamingApp GitHub Repository

Jenkins Portal: Jenkins Academics Portal

High-Level Architecture
Developer → GitHub → Jenkins Pipeline → Docker Build
→ Push to Amazon ECR → Deploy to EKS using Helm
→ Monitor via CloudWatch → Notifications via SNS

⚠️ IMPORTANT: Infrastructure Automation

Two approaches to set up infrastructure:

Option 1: TERRAFORM (RECOMMENDED ⭐⭐⭐)
- Automated infrastructure provisioning
- IaC (Infrastructure as Code)
- Reproducible and version-controlled
- Fast deployment (10-15 minutes)
- Easy to destroy and recreate
- See STEP 13A for complete Terraform guide

Option 2: Manual AWS Setup
- Step-by-step CLI commands
- Good for learning
- Slower and error-prone
- See STEP 14+ for manual steps

We recommend Option 1 (Terraform) for production deployments.

STEP 1 — Fork & Clone Repository
Fork Repository

Open:

StreamingApp Repository

Click:

Fork
Create your own copy

Example fork:

https://github.com/<your-username>/StreamingApp.git
Clone Your Fork
git clone https://github.com/<your-username>/StreamingApp.git
cd StreamingApp
Add Upstream Repository
git remote add upstream https://github.com/UnpredictablePrashant/StreamingApp.git

Verify:

git remote -v
Sync Fork with Upstream
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
STEP 2 — Analyze MERN Structure

StreamingApp Microservices Architecture

Your project is a microservices-based MERN application.

Based on the structure, the backend folder contains multiple independent services, and each service has its own Dockerfile.

That means:

You should NOT build one backend image
You MUST build separate Docker images for:
adminService
authService
chatService
streamingService
frontend
Actual Project Architecture
STREAMINGAPP/
│
├── backend/
│   ├── adminService/
│   │    └── Dockerfile
│   │
│   ├── authService/
│   │    └── Dockerfile
│   │
│   ├── chatService/
│   │    └── Dockerfile
│   │
│   └── streamingService/
│        └── Dockerfile
│
├── frontend/
│    └── Dockerfile
│
├── docker-compose.yml
└── README.md
Final DevOps Architecture
Developer
   ↓
GitHub Repository
   ↓
Jenkins CI/CD Pipeline
   ↓
Docker Build Per Microservice
   ↓
Amazon ECR Repositories
   ↓
Amazon EKS Cluster
   ↓
Helm Deployment
   ↓
Kubernetes Pods & Services
   ↓
CloudWatch Monitoring
   ↓
SNS Notifications
STEP 1 — Fork Repository

Open:

StreamingApp Repository

Fork into your GitHub account.

STEP 2 — Clone Repository
git clone https://github.com/<your-username>/StreamingApp.git

cd StreamingApp
STEP 3 — Verify Folder Structure

Run:

tree /F

Expected:

backend/
frontend/
docker-compose.yml
STEP 4 — Understand Microservices
Services
Service	Purpose
adminService	Admin APIs
authService	Authentication APIs
chatService	Chat & messaging
streamingService	Streaming APIs
frontend	React frontend

Each service:

Has its own Dockerfile
Runs independently
Deploys independently
Scales independently
STEP 5 — Build Docker Images

Go to project root:

cd StreamingApp
Build adminService
docker build -t admin-service ./backend/adminService
Build authService
docker build -t auth-service ./backend/authService
Build chatService
docker build -t chat-service ./backend/chatService
Build streamingService
docker build -t streaming-service ./backend/streamingService
Build Frontend
docker build -t streaming-frontend ./frontend
STEP 6 — Validate Images
docker images

Expected:

admin-service
auth-service
chat-service
streaming-service
streaming-frontend
STEP 7 — Test Application Locally

Your repo already includes:

docker-compose.yml

Run:

docker compose up --build

Verify:

Frontend accessible
APIs responding
Services communicating

Stop:

docker compose down
STEP 8 — Install AWS CLI

AWS CLI Installer

Verify:

aws --version
STEP 9 — Configure AWS CLI
aws configure

Provide:

Access Key
Secret Key
Region

Example:

ap-south-1
STEP 10 — Create Amazon ECR Repositories

Create separate repositories for every service.

adminService Repository:
aws ecr create-repository --repository-name admin-service
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:ap-south-1:130961287799:repository/admin-service",
        "registryId": "130961287799",
        "repositoryName": "admin-service",
        "repositoryUri": "130961287799.dkr.ecr.ap-south-1.amazonaws.com/admin-service",
        "createdAt": "2026-05-18T00:45:20.687000+05:30",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        },
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        }
    }
}
authService Repository:
aws ecr create-repository --repository-name auth-service
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:ap-south-1:130961287799:repository/auth-service",
        "registryId": "130961287799",
        "repositoryName": "auth-service",
        "repositoryUri": "130961287799.dkr.ecr.ap-south-1.amazonaws.com/auth-service",
        "createdAt": "2026-05-18T00:46:20.655000+05:30",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        },
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        }
    }
}
chatService Repository:
aws ecr create-repository --repository-name chat-service
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:ap-south-1:130961287799:repository/chat-service",
        "registryId": "130961287799",
        "repositoryName": "chat-service",
        "repositoryUri": "130961287799.dkr.ecr.ap-south-1.amazonaws.com/chat-service",
        "createdAt": "2026-05-18T00:46:46.036000+05:30",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        },
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        }
    }
}
streamingService Repository:
aws ecr create-repository --repository-name streaming-service
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:ap-south-1:130961287799:repository/streaming-service",
        "registryId": "130961287799",
        "repositoryName": "streaming-service",
        "repositoryUri": "130961287799.dkr.ecr.ap-south-1.amazonaws.com/streaming-service",
        "createdAt": "2026-05-18T00:47:11.456000+05:30",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        },
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        }
    }
}
Frontend Repository:
aws ecr create-repository --repository-name streaming-frontend

STEP 11 — Login to Amazon ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 130961287799.dkr.ecr.ap-south-1.amazonaws.com

STEP 12 — Tag Docker Images
adminService
docker tag admin-service:latest 130961287799.dkr.ecr.ap-south-1.amazonaws.com/admin-service:latest
authService
docker tag auth-service:latest 130961287799.dkr.ecr.ap-south-1.amazonaws.com/auth-service:latest
chatService
docker tag chat-service:latest 130961287799.dkr.ecr.ap-south-1.amazonaws.com/chat-service:latest
streamingService
docker tag streaming-service:latest 130961287799.dkr.ecr.ap-south-1.amazonaws.com/streaming-service:latest
Frontend
docker tag streaming-frontend:latest 130961287799.dkr.ecr.ap-south-1.amazonaws.com/streaming-frontend:latest

STEP 13 — Push Images to ECR
adminService
docker push 130961287799.dkr.ecr.ap-south-1.amazonaws.com/admin-service:latest
authService
docker push 130961287799.dkr.ecr.ap-south-1.amazonaws.com/auth-service:latest
chatService
docker push 130961287799.dkr.ecr.ap-south-1.amazonaws.com/chat-service:latest
streamingService
docker push 130961287799.dkr.ecr.ap-south-1.amazonaws.com/streaming-service:latest
Frontend
docker push 130961287799.dkr.ecr.ap-south-1.amazonaws.com/streaming-frontend:latest
------------------------completed on 17 May 26------------------

STEP 13A — Infrastructure as Code with Terraform (RECOMMENDED)

Instead of manual AWS setup, use Terraform to automate infrastructure provisioning.

Prerequisites:

Terraform >= 1.0
AWS CLI v2 configured
Git

File Structure:

The terraform/ directory contains:

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
├── monitoring.tf               # CloudWatch and SNS
├── terraform.tfvars            # Dev environment values
├── terraform.prod.tfvars       # Prod environment values
└── README.md                   # Detailed guide

What Terraform Deploys:

✓ VPC with public/private subnets
✓ 5 ECR repositories (one per service)
✓ EKS cluster with auto-scaling node group
✓ Jenkins EC2 instance (fully configured)
✓ IAM roles and policies
✓ Security groups
✓ CloudWatch log groups
✓ SNS topic for alerts
✓ CloudWatch alarms

STEP 13A.1 — Navigate to Terraform Directory

cd terraform

STEP 13A.2 — Initialize Terraform

terraform init

Output:

Initializing the backend...
Initializing provider plugins...
Terraform has been successfully configured!

STEP 13A.3 — Validate Configuration

terraform validate

Expected:

Success! The configuration is valid.

STEP 13A.4 — Review Deployment Plan (Dev)

terraform plan -var-file=terraform.tfvars -out=dev.plan

Review the resources that will be created:

+  aws_vpc.main
+  aws_eks_cluster.main
+  aws_ecr_repository.auth
+  aws_ecr_repository.streaming
+  aws_ecr_repository.admin
+  aws_ecr_repository.chat
+  aws_ecr_repository.frontend
+  aws_instance.jenkins
+  (and many more)

STEP 13A.5 — Deploy Infrastructure (Dev)

terraform apply dev.plan

Expected output (take 10-15 minutes):

Apply complete! Resources: 45 added, 0 changed, 0 destroyed.

Outputs:

jenkins_url = "http://52.172.xxx.xxx:8080"
eks_cluster_name = "streamingapp-cluster"
eks_cluster_endpoint = "https://xxx.eks.ap-south-1.amazonaws.com"
ecr_repository_urls = {
  "auth_service" = "130961287799.dkr.ecr.ap-south-1.amazonaws.com/streamingapp-auth-service"
  "streaming_service" = "130961287799.dkr.ecr.ap-south-1.amazonaws.com/streamingapp-streaming-service"
  "admin_service" = "130961287799.dkr.ecr.ap-south-1.amazonaws.com/streamingapp-admin-service"
  "chat_service" = "130961287799.dkr.ecr.ap-south-1.amazonaws.com/streamingapp-chat-service"
  "frontend" = "130961287799.dkr.ecr.ap-south-1.amazonaws.com/streamingapp-frontend"
}

STEP 13A.6 — Verify Deployment

Check EKS cluster:

aws eks describe-cluster --name streamingapp-cluster

Check EC2 instances:

aws ec2 describe-instances --filters "Name=tag:Name,Values=streamingapp-jenkins"

Check ECR repositories:

aws ecr describe-repositories --repository-names streamingapp-auth-service

STEP 13A.7 — Get Jenkins Public IP

terraform output jenkins_public_ip

Example output:

52.172.123.456

STEP 13A.8 — Get EKS Kubeconfig

Run the command from Terraform output:

terraform output kubeconfig_command

Example:

aws eks update-kubeconfig --name streamingapp-cluster --region ap-south-1

Then verify:

kubectl get nodes

Expected:

NAME                          STATUS   ROLES    AGE
ip-10-0-10-xxx.ec2.internal  Ready    <none>   2m
ip-10-0-11-xxx.ec2.internal  Ready    <none>   2m

STEP 13A.9 — Configure Production Deployment (Optional)

For production, use different values:

terraform plan -var-file=terraform.prod.tfvars -out=prod.plan

terraform apply prod.plan

Differences between Dev and Prod:

Config	Dev	Prod
Node Type	t3.medium	t3.large
Desired Nodes	2	3
Max Nodes	5	10
Jenkins Type	t3.medium	t3.large
EBS Volume	50GB	100GB
Auto-scaling	Yes	Yes

STEP 13A.10 — Verify All Resources

terraform output

View all created resources and their values:

vpc_id = "vpc-0xxx"
public_subnet_ids = ["subnet-0xxx", "subnet-0yyy"]
private_subnet_ids = ["subnet-0zzz", "subnet-0www"]
eks_cluster_name = "streamingapp-cluster"
jenkins_url = "http://52.172.123.456:8080"
sns_topic_arn = "arn:aws:sns:ap-south-1:130961287799:streamingapp-deployment-alerts"

STEP 13A.11 — Destroy Infrastructure (When Done)

WARNING: This cannot be undone!

terraform destroy -var-file=terraform.tfvars

Confirm by typing:

yes

STEP 14 — Setup Jenkins EC2

Create EC2:

Ubuntu 22.04
t2.medium
Open ports:
22
8080

STEP 15 — Install Jenkins
Install Java
sudo apt update

sudo apt install openjdk-17-jdk -y
Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update

sudo apt install jenkins -y

STEP 16 — Install Docker on Jenkins Server
sudo apt install docker.io -y

Add Jenkins to Docker group:

sudo usermod -aG docker jenkins

Restart:

sudo systemctl restart jenkins
sudo systemctl restart docker
STEP 17 — Jenkins Plugins

Install:

Docker Pipeline
GitHub Integration
Pipeline
Kubernetes
AWS Credentials
STEP 18 — Configure Jenkins Credentials

Add:

AWS Credentials
GitHub Credentials

STEP 19 — Create Jenkinsfile

Create:

Jenkinsfile
Complete Jenkinsfile for Microservices
pipeline {
    agent any

    environment {

        AWS_REGION = 'ap-south-1'
        ACCOUNT_ID = 'YOUR_ACCOUNT_ID'

        ADMIN_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/admin-service"

        AUTH_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/auth-service"

        CHAT_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/chat-service"

        STREAM_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/streaming-service"

        FRONTEND_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/streaming-frontend"
    }

    stages {

        stage('Clone Repository') {
            steps {
                git 'https://github.com/<your-username>/StreamingApp.git'
            }
        }

        stage('Build Docker Images') {
            steps {

                sh 'docker build -t admin-service ./backend/adminService'

                sh 'docker build -t auth-service ./backend/authService'

                sh 'docker build -t chat-service ./backend/chatService'

                sh 'docker build -t streaming-service ./backend/streamingService'

                sh 'docker build -t streaming-frontend ./frontend'
            }
        }

        stage('Login to ECR') {
            steps {
                withDockerRegistry(credentialsId: 'aws-credentials-id', url: 'https://130961287799.dkr.ecr.ap-south-1.amazonaws.com')
                #sh '''
                #aws ecr get-login-password --region $AWS_REGION | \
                #docker login --username AWS --password-stdin \
                #$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                '''
            }
        }

        stage('Push Images') {
            steps {

                sh '''
                docker tag admin-service:latest $ADMIN_REPO:latest
                docker push $ADMIN_REPO:latest
                '''

                sh '''
                docker tag auth-service:latest $AUTH_REPO:latest
                docker push $AUTH_REPO:latest
                '''

                sh '''
                docker tag chat-service:latest $CHAT_REPO:latest
                docker push $CHAT_REPO:latest
                '''

                sh '''
                docker tag streaming-service:latest $STREAM_REPO:latest
                docker push $STREAM_REPO:latest
                '''

                sh '''
                docker tag streaming-frontend:latest $FRONTEND_REPO:latest
                docker push $FRONTEND_REPO:latest
                '''
            }
        }
    }
}
STEP 20 — Create EKS Cluster
eksctl create cluster --name streaming-cluster --region ap-south-1 --nodegroup-name workers --node-type t3.medium --nodes 2

STEP 21 — Verify Cluster

kubectl get nodes

STEP 22 — Install Helm

Helm Official Website

STEP 23 — Create Helm Chart
helm create streaming-chart

STEP 24 — Configure values.yaml
adminService:
  image:
    repository: 130961287799.dkr.ecr.ap-south-1.amazonaws.com/admin-service
    tag: latest

authService:
  image:
    repository: 130961287799.dkr.ecr.ap-south-1.amazonaws.com/auth-service
    tag: latest

chatService:
  image:
    repository: 130961287799.dkr.ecr.ap-south-1.amazonaws.com/chat-service
    tag: latest

streamingService:
  image:
    repository: 130961287799.dkr.ecr.ap-south-1.amazonaws.com/streaming-service
    tag: latest

frontend:
  image:
    repository: 130961287799.dkr.ecr.ap-south-1.amazonaws.com/streaming-frontend
    tag: latest

STEP 25 — Deploy to Kubernetes
helm install streaming-app ./streaming-chart

STEP 26 — Verify Deployment
kubectl get pods

kubectl get svc

kubectl get deployments
STEP 27 — Enable Auto Scaling

Each microservice can scale independently.

Example:

kubectl autoscale deployment auth-service \
--cpu-percent=70 \
--min=2 \
--max=5

STEP 28 — Monitoring

Install:

CloudWatch Agent
Fluent Bit

Monitor:

Pods
CPU
Memory
Logs
STEP 29 — SNS Notifications

Create Topic:

aws sns create-topic --name deployment-alerts

Subscribe Email:

aws sns subscribe --topic-arn arn:aws:sns:ap-south-1:130961287799:deployment-alerts --protocol email --notification-endpoint arun.sdpr@gmail.com

STEP 30 — Final Validation

Verify:

Frontend accessible
All APIs working
Jenkins builds successful
Pods healthy
Logs visible in CloudWatch
Final Deliverables
README.md
Jenkinsfile
docker-compose.yml
helm/
k8s/
screenshots/

strategy:
  type: RollingUpdate
Useful Commands Cheat Sheet
Docker
docker ps
docker images
docker logs <container>
Kubernetes
kubectl get all
kubectl describe pod <pod-name>
kubectl logs <pod-name>
Helm
helm list
helm upgrade
helm uninstall
Official References
AWS EKS Documentation
Jenkins Documentation
Docker Documentation
Kubernetes Documentation
Amazon ECR Documentation
Terraform Documentation
AWS EKS Best Practices

## Infrastructure Architecture with Terraform

Complete end-to-end infrastructure architecture for StreamingApp using Infrastructure as Code (IaC):

### AWS Infrastructure Components

```
┌─────────────────────────────────────────────────────────────────┐
│                        AWS Account (130961287799)                │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                     VPC (10.0.0.0/16)                   │   │
│  │                                                           │   │
│  │  ┌──────────────────────────────────────────────────┐  │   │
│  │  │         Public Subnets (10.0.1.0/24, 10.0.2.0/24)   │  │   │
│  │  │  [Jenkins EC2]   [NAT Gateway]   [IGW]           │  │   │
│  │  └──────────────────────────────────────────────────┘  │   │
│  │                          ↓                              │   │
│  │  ┌──────────────────────────────────────────────────┐  │   │
│  │  │      Private Subnets (10.0.10.0/24, 10.0.11.0/24) │  │   │
│  │  │  [EKS Node 1]    [EKS Node 2]   [EKS Node 3]    │  │   │
│  │  └──────────────────────────────────────────────────┘  │   │
│  │                                                           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │            Amazon EKS Cluster (Kubernetes 1.28)         │   │
│  │  - Control Plane: Managed by AWS                       │   │
│  │  - Worker Nodes: Auto-scaling (1-5 nodes)             │   │
│  │  - Add-ons: VPC CNI, CoreDNS, kube-proxy              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐           │
│  │     ECR      │ │  CloudWatch  │ │     SNS      │           │
│  │              │ │              │ │              │           │
│  │ Auth Service │ │ Logs & Metrics│ │ Alerts      │           │
│  │ Stream Svc   │ │ Dashboards   │ │ Notifications           │
│  │ Admin Svc    │ │ Alarms       │ │              │           │
│  │ Chat Svc     │ │              │ │              │           │
│  │ Frontend     │ │              │ │              │           │
│  └──────────────┘ └──────────────┘ └──────────────┘           │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Terraform Resource Deployment Summary

**Total Resources Deployed: 45+**

**1. VPC & Networking (9 resources)**
   - VPC
   - 2 Public Subnets
   - 2 Private Subnets
   - Internet Gateway
   - NAT Gateway
   - 2 Route Tables
   - Route Table Associations

**2. Amazon ECR (5 resources)**
   - streamingapp-auth-service
   - streamingapp-streaming-service
   - streamingapp-admin-service
   - streamingapp-chat-service
   - streamingapp-frontend

**3. Amazon EKS (4 resources)**
   - EKS Cluster
   - Node Group (2-5 nodes, auto-scaling)
   - VPC CNI Addon
   - CoreDNS Addon
   - kube-proxy Addon

**4. Jenkins EC2 (2 resources)**
   - EC2 Instance (t3.medium)
   - EBS Volume (50GB)
   - Elastic IP

**5. Security (9 resources)**
   - EKS Cluster Security Group
   - EKS Node Security Group
   - Jenkins Security Group
   - ALB Security Group
   - IAM Role for EKS Cluster
   - IAM Role for EKS Nodes
   - IAM Role for Jenkins
   - 3 IAM Policy Attachments

**6. Monitoring & Alerts (7 resources)**
   - CloudWatch Log Group (EKS)
   - CloudWatch Log Group (VPC Flow Logs)
   - SNS Topic
   - SNS Subscription (Email)
   - CloudWatch Alarms (3x)

### Key Infrastructure Features

✅ **High Availability**
   - Multi-AZ deployment (2 AZs)
   - Auto-scaling node groups
   - Managed database (MongoDB)

✅ **Security**
   - VPC with private subnets for EKS nodes
   - Security groups with least privilege
   - IAM roles for service authentication
   - Encrypted EBS volumes
   - Encryption at transit and rest

✅ **Monitoring & Observability**
   - EKS Control Plane Logging
   - VPC Flow Logs
   - CloudWatch Dashboards
   - SNS Notifications
   - Custom Alarms

✅ **Cost Optimization**
   - On-demand instances (can be switched to spot)
   - Auto-scaling based on demand
   - Efficient resource sizing
   - Auto cleanup of old ECR images

### Deployment Timeline

| Stage | Time | Resources |
|-------|------|-----------|
| VPC Creation | 2-3 min | VPC, Subnets, IGW, NAT |
| ECR Repositories | 1 min | 5 ECR repos |
| EKS Cluster | 5-7 min | Control plane |
| EKS Node Group | 3-5 min | Worker nodes |
| Jenkins EC2 | 2-3 min | Jenkins instance |
| Jenkins Bootstrap | 3-5 min | Java, Jenkins, Docker |
| **Total** | **10-15 min** | **45+ resources** |

### Cost Estimation (Dev Environment)

| Resource | Monthly Cost |
|----------|--------------|
| EKS Cluster | $73.00 |
| 2 x t3.medium nodes | $60.00 |
| Jenkins t3.medium | $30.00 |
| NAT Gateway | $32.00 |
| EBS Volumes (100GB) | $10.00 |
| Data Transfer | ~$5.00 |
| **Total** | **~$210/month** |

*Note: Costs vary by region and usage patterns*

### Terraform Best Practices Used

✅ Modular configuration (vpc.tf, eks.tf, iam.tf, etc.)
✅ Environment-based variables (dev/prod)
✅ Comprehensive outputs for easy access
✅ IAM least privilege principle
✅ Security groups with specific rules
✅ Auto-scaling for EKS nodes
✅ Encryption everywhere
✅ CloudWatch logging enabled
✅ SNS notifications setup
✅ VPC Flow Logs for debugging

### Files Generated by Terraform

```
terraform/
├── main.tf                  # Provider & backend config
├── variables.tf             # Input variables
├── outputs.tf               # Output values
├── data.tf                  # Data sources
├── vpc.tf                   # VPC & networking
├── ecr.tf                   # ECR repositories
├── eks.tf                   # EKS cluster & nodes
├── iam.tf                   # IAM roles & policies
├── security_groups.tf       # Security groups
├── jenkins.tf               # Jenkins EC2 instance
├── monitoring.tf            # CloudWatch & SNS
├── jenkins_bootstrap.sh     # Jenkins installation script
├── terraform.tfvars         # Dev environment values
├── terraform.prod.tfvars    # Prod environment values
├── README.md                # Detailed setup guide
├── BACKEND.md               # S3 backend configuration
└── .terraform.tfstate       # State file (local)
```

### Directory Structure After Deployment

```
StreamingApp/
├── backend/
│   ├── authService/
│   ├── streamingService/
│   ├── adminService/
│   └── chatService/
├── frontend/
├── helm/
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-dev.yaml
│   └── values-prod.yaml
├── terraform/
│   ├── *.tf files
│   ├── terraform.tfvars
│   └── README.md
├── scripts/
│   └── notify.sh
├── Jenkinsfile
├── docker-compose.yml
├── guide.md (this file)
└── JENKINS_SETUP.md
```

### Next Steps After Infrastructure Deployment

1. **Configure Jenkins**
   - Access: http://<jenkins-public-ip>:8080
   - Install plugins (Docker, Kubernetes, AWS)
   - Add credentials (AWS, GitHub)

2. **Deploy Applications**
   - Use Helm charts in helm/ directory
   - Configure ingress
   - Set up DNS records

3. **Monitor & Scale**
   - Access CloudWatch Dashboard
   - Set up custom metrics
   - Configure auto-scaling policies

4. **Backup & Disaster Recovery**
   - Setup S3 backend for Terraform state
   - Configure EBS snapshots
   - Test disaster recovery procedures

## Complete DevOps Pipeline Summary

The StreamingApp DevOps infrastructure includes:

✅ Source Control: GitHub
✅ CI/CD: Jenkins (containerized)
✅ Container Registry: Amazon ECR
✅ Container Orchestration: Amazon EKS (Kubernetes)
✅ Infrastructure as Code: Terraform
✅ Deployment: Helm
✅ Monitoring: CloudWatch
✅ Alerting: SNS + Email
✅ Logging: CloudWatch Logs
✅ Load Balancing: Kubernetes Ingress/ALB

### Deployment Options

**Option 1: Terraform (Recommended)**
- Fastest: 10-15 minutes
- IaC: Version-controlled
- Reproducible: Identical every time
- Destroyable: Cleanup with one command

**Option 2: Manual AWS CLI**
- Learning: Good for understanding AWS
- Flexibility: Step-by-step control
- Slower: 30-45 minutes
- Error-prone: Manual steps

### Team Roles & Responsibilities

| Role | Responsibilities |
|------|-----------------|
| DevOps Engineer | Terraform, Jenkins, monitoring |
| Platform Engineer | Kubernetes, Helm, networking |
| Developer | Application code, Dockerfile |
| SRE | Incident response, on-call |

### Support & Troubleshooting

**For Terraform Issues:**
- See terraform/README.md
- See terraform/BACKEND.md

**For Jenkins Setup:**
- See JENKINS_SETUP.md
- Access: http://<jenkins-ip>:8080

**For EKS Issues:**
- Check: kubectl get nodes
- Logs: kubectl logs <pod-name> -n <namespace>
- Events: kubectl describe pod <pod-name> -n <namespace>

### Security Checklist

- [ ] Update IAM policies (least privilege)
- [ ] Configure VPN/IP restrictions
- [ ] Enable MFA on AWS account
- [ ] Rotate credentials regularly
- [ ] Enable encryption (EBS, RDS)
- [ ] Configure security groups properly
- [ ] Enable VPC Flow Logs
- [ ] Setup CloudTrail logging
- [ ] Review CloudWatch alarms
- [ ] Test disaster recovery

### Maintenance Tasks

| Frequency | Task |
|-----------|------|
| Daily | Monitor CloudWatch dashboards |
| Weekly | Review logs and alarms |
| Monthly | Update EKS add-ons |
| Monthly | Rotate IAM credentials |
| Quarterly | Review and optimize costs |
| Quarterly | Update Terraform modules |
| Yearly | Disaster recovery drill |

---

**Last Updated:** May 18, 2026
**Infrastructure Version:** 1.0
**EKS Version:** 1.28+
**Terraform Version:** >= 1.0