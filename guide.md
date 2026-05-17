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

Typical structure:

StreamingApp/
 ├── frontend/
 ├── backend/
 ├── package.json
STEP 3 — Dockerize Frontend & Backend
Backend Dockerfile

Create:

backend/Dockerfile
FROM node:18

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 5000

CMD ["npm", "start"]
Frontend Dockerfile

Create:

frontend/Dockerfile
FROM node:18 as build

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

FROM nginx:latest

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
STEP 4 — Test Docker Locally
Backend
cd backend

docker build -t streaming-backend .

docker run -p 5000:5000 streaming-backend
Frontend
cd frontend

docker build -t streaming-frontend .

docker run -p 80:80 streaming-frontend
STEP 5 — AWS Setup
Install AWS CLI
Windows

AWS CLI Installer

Verify:

aws --version
Configure AWS CLI
aws configure

Enter:

Access Key
Secret Key
Region
Output format

Example:
Region: ap-south-1
Output: json

STEP 6 — Create Amazon ECR Repositories
Backend Repository:
aws ecr create-repository --repository-name streaming-backend
C:\Users\arunkumar\Documents\Assignments>aws ecr create-repository --repository-name streaming-backend
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:ap-south-1:130961287799:repository/streaming-backend",
        "registryId": "130961287799",
        "repositoryName": "streaming-backend",
        "repositoryUri": "130961287799.dkr.ecr.ap-south-1.amazonaws.com/streaming-backend",
        "createdAt": "2026-05-17T17:43:53.829000+05:30",
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
C:\Users\arunkumar\Documents\Assignments>aws ecr create-repository --repository-name streaming-frontend
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:ap-south-1:130961287799:repository/streaming-frontend",
        "registryId": "130961287799",
        "repositoryName": "streaming-frontend",
        "repositoryUri": "130961287799.dkr.ecr.ap-south-1.amazonaws.com/streaming-frontend",
        "createdAt": "2026-05-17T17:45:08.915000+05:30",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        },
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        }
    }
}

STEP 7 — Login to ECR
'''aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com'''
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 130961287799.dkr.ecr.ap-south-1.amazonaws.com

STEP 8 — Build & Push Images
Backend
docker build -t streaming-backend ./backend

Tag:

docker tag streaming-backend:latest \
#<ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/#streaming-backend:latest

docker tag streaming-backend:latest 130961287799.dkr.ecr.ap-south-1.amazonaws.com/streaming-backend:latest

Push:

docker push \
<ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/streaming-backend:latest
Frontend
docker build -t streaming-frontend ./frontend

Tag:

docker tag streaming-frontend:latest \
<ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/streaming-frontend:latest

Push:

docker push \
<ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/streaming-frontend:latest
STEP 9 — Launch Jenkins EC2 Instance

Create EC2:

Ubuntu 22.04
t2.medium
30GB storage
Open ports:
22
8080
STEP 10 — Install Jenkins
Update Server
sudo apt update
Install Java
sudo apt install openjdk-17-jdk -y
Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y
Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
Access Jenkins
http://<EC2-PUBLIC-IP>:8080
Unlock Jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

Install:

Suggested Plugins

Create admin user.

STEP 11 — Install Docker on Jenkins Server
sudo apt install docker.io -y

Add Jenkins user:

sudo usermod -aG docker jenkins

Restart:

sudo systemctl restart jenkins
sudo systemctl restart docker
STEP 12 — Install Required Jenkins Plugins

Go:
Manage Jenkins → Plugins

Install:

Docker Pipeline
GitHub Integration
Pipeline
Kubernetes
AWS Credentials
Blue Ocean
STEP 13 — Configure Jenkins Credentials

Add:

AWS Access Key
AWS Secret Key
GitHub Token (optional)

Path:
Manage Jenkins → Credentials

STEP 14 — Create Jenkins Pipeline

Create:

Jenkinsfile
Sample Jenkinsfile
pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        ACCOUNT_ID = 'YOUR_ACCOUNT_ID'

        FRONTEND_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/streaming-frontend"
        BACKEND_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/streaming-backend"
    }

    stages {

        stage('Clone Repository') {
            steps {
                git 'https://github.com/<your-username>/StreamingApp.git'
            }
        }

        stage('Build Backend') {
            steps {
                sh 'docker build -t streaming-backend ./backend'
            }
        }

        stage('Build Frontend') {
            steps {
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

        stage('Push Backend') {
            steps {
                sh '''
                docker tag streaming-backend:latest $BACKEND_REPO:latest
                docker push $BACKEND_REPO:latest
                '''
            }
        }

        stage('Push Frontend') {
            steps {
                sh '''
                docker tag streaming-frontend:latest $FRONTEND_REPO:latest
                docker push $FRONTEND_REPO:latest
                '''
            }
        }
    }
}
STEP 15 — Configure GitHub Webhook

GitHub Repo → Settings → Webhooks

Add:

http://<JENKINS-IP>:8080/github-webhook/

Content type:

application/json

Events:

Just push event
STEP 16 — Install eksctl & kubectl
Install kubectl

kubectl Installation Guide

Install eksctl

eksctl Official Guide

STEP 17 — Create EKS Cluster
eksctl create cluster \
--name streaming-cluster \
--region ap-south-1 \
--nodegroup-name workers \
--node-type t3.medium \
--nodes 2

This takes ~15–20 mins.

STEP 18 — Verify Cluster
kubectl get nodes
STEP 19 — Install Helm

Helm Official Website

Install:

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
STEP 20 — Create Helm Chart
helm create streaming-chart

Structure:

streaming-chart/
 ├── templates/
 ├── values.yaml
 ├── Chart.yaml
STEP 21 — Configure values.yaml
frontend:
  image:
    repository: <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/streaming-frontend
    tag: latest

backend:
  image:
    repository: <ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/streaming-backend
    tag: latest
STEP 22 — Deploy Using Helm
helm install streaming-app ./streaming-chart

Verify:

kubectl get pods
kubectl get svc
STEP 23 — Expose Application

Use:

LoadBalancer Service

Example:

type: LoadBalancer

Apply:

kubectl apply -f service.yaml
STEP 24 — Enable Auto Scaling
Horizontal Pod Autoscaler
kubectl autoscale deployment backend \
--cpu-percent=70 \
--min=2 \
--max=5
STEP 25 — Monitoring with CloudWatch
Install CloudWatch Agent
helm repo add aws-observability https://aws.github.io/eks-charts
helm install cloudwatch-agent aws-observability/aws-cloudwatch-metrics
STEP 26 — Logging with CloudWatch Logs

Install Fluent Bit:

kubectl apply -f \
https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit.yaml
STEP 27 — SNS Notifications (Bonus)
Create SNS Topic
aws sns create-topic \
--name deployment-alerts
Subscribe Email
aws sns subscribe \
--topic-arn <TOPIC_ARN> \
--protocol email \
--notification-endpoint yourmail@gmail.com
STEP 28 — Integrate SNS with Jenkins

Add post-build step:

post {
    success {
        sh '''
        aws sns publish \
        --topic-arn <TOPIC_ARN> \
        --message "Deployment Successful"
        '''
    }

    failure {
        sh '''
        aws sns publish \
        --topic-arn <TOPIC_ARN> \
        --message "Deployment Failed"
        '''
    }
}
STEP 29 — Final Validation Checklist
Verify
Frontend
Accessible via LoadBalancer URL
Backend
APIs working
Docker
Images visible in ECR
Jenkins
Auto-trigger on Git push
Kubernetes
Pods healthy

Check:

kubectl get pods
kubectl get svc
kubectl get deployments
STEP 30 — Documentation Structure

Create:

README.md
architecture-diagram.png
jenkins/
helm/
k8s/
screenshots/
Recommended README Sections
Project Overview
Architecture Diagram
Tools Used
CI/CD Pipeline
EKS Deployment
Helm Deployment
Monitoring
Scaling
SNS Notifications
Screenshots
Challenges Faced
Future Improvements
Suggested Architecture Diagram Components

Use:

GitHub
Jenkins
Docker
Amazon ECR
Amazon EKS
CloudWatch
SNS
Users

You can create diagrams using:

Draw.io

Final Submission

Submit:

GitHub repository link
README.md
Screenshots
Jenkinsfile
Helm charts
Kubernetes YAMLs

Example:

https://github.com/<your-username>/StreamingApp
Extra Pro Tips
Use Separate Namespaces
kubectl create namespace streaming
Use Secrets for Sensitive Data
kubectl create secret generic app-secret \
--from-literal=MONGO_URI=<your-uri>
Enable Rolling Updates

Deployment YAML:

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