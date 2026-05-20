# Jenkins Setup Guide for StreamingApp CI/CD Pipeline

## Prerequisites

- Jenkins server (v2.375+) with Docker and kubectl installed
- AWS account with ECR repositories
- EKS cluster(s) for dev, staging, and prod environments
- GitHub repository access
- Helm 3.x installed

## Jenkins Plugins Required

```
1. Pipeline Plugin
2. Docker Pipeline Plugin
3. AWS Steps Plugin
4. Kubernetes CLI Plugin
5. GitHub Integration Plugin
6. Email Extension Plugin
7. Slack Notification Plugin (optional)
```

### Install Plugins
1. Go to **Manage Jenkins** → **Manage Plugins** → **Available**
2. Search for each plugin above and click **Install without restart**
3. Restart Jenkins after installation

## AWS Credentials Setup

### 1. Create IAM User for Jenkins

```bash
# Create IAM user
aws iam create-user --user-name jenkins-ci

# Attach ECR permissions
aws iam attach-user-policy --user-name arunkumar.v --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser

# Attach EKS permissions
aws iam attach-user-policy --user-name arunkumar.v --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

# Generate access keys
aws iam create-access-key --user-name jenkins-ci
```

### 2. Add AWS Credentials to Jenkins

1. Navigate to **Manage Jenkins** → **Manage Credentials** → **(global)**
2. Click **Add Credentials**
   - **Kind**: AWS Credentials
   - **Access Key ID**: From IAM user creation
   - **Secret Access Key**: From IAM user creation
   - **ID**: `aws-credentials`
   - Click **Create**

### 3. Store AWS Account ID

1. Click **Add Credentials** again
   - **Kind**: Secret text
   - **Secret**: Your AWS Account ID (12 digits)
   - **ID**: `AWS_ACCOUNT_ID`
   - Click **Create**

## GitHub Integration

### 1. Create GitHub Personal Access Token

1. Go to GitHub → **Settings** → **Developer settings** → **Personal access tokens**
2. Click **Generate new token (classic)**
3. Select scopes:
   - `repo` (full control of private repositories)
   - `admin:repo_hook` (write access to hooks)
4. Copy the token

### 2. Add GitHub Credentials to Jenkins

1. Navigate to **Manage Jenkins** → **Manage Credentials** → **(global)**
2. Click **Add Credentials**
   - **Kind**: Username with password
   - **Username**: `github`
   - **Password**: Paste the GitHub PAT
   - **ID**: `github-credentials`
   - Click **Create**

## Create Jenkins Pipeline Job

### 1. New Pipeline Job

1. Click **New Item**
2. Enter job name: `StreamingApp-CI-CD`
3. Select **Pipeline**
4. Click **OK**

### 2. Configure Pipeline

**General Tab:**
- Enable: ✓ GitHub project
- Project url: `https://github.com/<your-username>/StreamingApp`

**Build Triggers Tab:**
- ✓ GitHub hook trigger for GITscm polling

**Pipeline Tab:**
- **Definition**: Pipeline script from SCM
- **SCM**: Git
  - **Repository URL**: `https://github.com/<your-username>/StreamingApp.git`
  - **Credentials**: Select `github-credentials`
  - **Branch Specifier**: `*/main`
  - **Script Path**: `Jenkinsfile`

### 3. Save Configuration

Click **Save**

## GitHub Webhook Configuration

### 1. Add Jenkins Webhook to GitHub

1. Go to your GitHub repository
2. Navigate to **Settings** → **Webhooks** → **Add webhook**
3. Configure:
   - **Payload URL**: `http://<jenkins-url>/github-webhook/`
   - **Content type**: `application/json`
   - **Which events would you like to trigger this webhook?**: Push events + Pull requests
4. Click **Add webhook**

## Environment Variables Configuration

Add the following environment variables to Jenkins job or `.env` files:

### ECR Configuration
```
AWS_REGION=ap-south-1
AWS_ACCOUNT_ID=<your-account-id>
```

### Frontend Build Arguments
```
REACT_APP_AUTH_API_URL=https://auth.streamingapp.com/api
REACT_APP_STREAMING_API_URL=https://stream.streamingapp.com/api
REACT_APP_STREAMING_PUBLIC_URL=https://stream.streamingapp.com
REACT_APP_ADMIN_API_URL=https://admin.streamingapp.com/api/admin
REACT_APP_CHAT_API_URL=https://chat.streamingapp.com/api/chat
REACT_APP_CHAT_SOCKET_URL=https://chat.streamingapp.com
```

### EKS Configuration
```
EKS_CLUSTER_DEV=streamingapp-dev
EKS_CLUSTER_STAGING=streamingapp-staging
EKS_CLUSTER_PROD=streamingapp-prod
```

## ECR Repository Setup

Create repositories for each service:

```bash
# Create repositories
aws ecr create-repository \
  --repository-name streamingapp-auth \
  --region ap-south-1

aws ecr create-repository \
  --repository-name streamingapp-streaming \
  --region ap-south-1

aws ecr create-repository \
  --repository-name streamingapp-admin \
  --region ap-south-1

aws ecr create-repository \
  --repository-name streamingapp-chat \
  --region ap-south-1

aws ecr create-repository \
  --repository-name streamingapp-frontend \
  --region ap-south-1

# Set lifecycle policy to clean old images (optional)
aws ecr put-lifecycle-policy \
  --repository-name streamingapp-auth \
  --lifecycle-policy-text file://ecr-lifecycle-policy.json \
  --region ap-south-1
```

## ECR Lifecycle Policy (optional)

Create `ecr-lifecycle-policy.json`:

```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

## Kubernetes Namespace Setup

```bash
# Create namespaces
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace prod

# Create image pull secrets
kubectl create secret docker-registry ecr-registry \
  --docker-server=<account-id>.dkr.ecr.ap-south-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  -n dev

# Repeat for staging and prod
```

## Helm Chart Structure (Optional)

If using Helm for deployment, create this structure:

```
helm/streamingapp/
├── Chart.yaml
├── values.yaml
├── values-dev.yaml
├── values-staging.yaml
├── values-prod.yaml
├── templates/
│   ├── auth-deployment.yaml
│   ├── streaming-deployment.yaml
│   ├── admin-deployment.yaml
│   ├── chat-deployment.yaml
│   ├── frontend-deployment.yaml
│   ├── services.yaml
│   └── ingress.yaml
```

## Running the Pipeline

### Automatic Trigger
- Push to GitHub repository → Jenkins automatically triggers the build

### Manual Trigger
1. Go to Jenkins job: `StreamingApp-CI-CD`
2. Click **Build with Parameters**
3. Select:
   - **ENVIRONMENT**: dev/staging/prod
   - **DEPLOY_TO_EKS**: Check to deploy after build
4. Click **Build**

## Monitoring & Logs

### View Build Logs
1. Click on build number in Jenkins
2. Click **Console Output** to view real-time logs

### CloudWatch Monitoring
```bash
# View logs from EKS
kubectl logs -n dev deployment/auth --follow

# Check pod status
kubectl get pods -n dev
kubectl describe pod <pod-name> -n dev
```

## Troubleshooting

### Build Failures

1. **Docker build fails**
   - Check Dockerfile syntax
   - Verify base images are available
   - Check build context paths

2. **ECR push fails**
   - Verify IAM permissions
   - Check ECR repository exists
   - Verify AWS credentials in Jenkins

3. **EKS deployment fails**
   - Check kubectl can access cluster: `kubectl cluster-info`
   - Verify namespace exists
   - Check image pull secrets
   - View pod events: `kubectl describe pod <pod-name> -n <namespace>`

### Testing the Pipeline

```bash
# Test ECR login
aws ecr get-login-password | docker login \
  --username AWS \
  --password-stdin <account-id>.dkr.ecr.ap-south-1.amazonaws.com

# Test kubectl access
kubectl get nodes

# Test image pull
docker pull <account-id>.dkr.ecr.ap-south-1.amazonaws.com/streamingapp-auth:latest
```

## Best Practices

1. **Use separate repositories for each environment** (dev, staging, prod)
2. **Tag images with both commit hash and branch name**
3. **Implement automated rollback** on deployment failure
4. **Set up monitoring and alerting** on EKS pods
5. **Use secrets management** (AWS Secrets Manager) for sensitive data
6. **Implement blue-green deployments** for zero-downtime updates
7. **Use image scanning** (Trivy) before production deployment
8. **Maintain separate kubeconfig** for each environment

## Additional Resources

- [Jenkins Pipeline Documentation](https://jenkins.io/doc/book/pipeline/)
- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
