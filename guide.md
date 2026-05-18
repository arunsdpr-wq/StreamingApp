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

                sh '''
                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin \
                $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
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

aws sns create-topic \
--name deployment-alerts

Subscribe Email:

aws sns subscribe \
--topic-arn <TOPIC_ARN> \
--protocol email \
--notification-endpoint yourmail@gmail.com
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