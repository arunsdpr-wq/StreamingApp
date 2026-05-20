# Terraform Backend Configuration Guide

## S3 Backend Setup

To use remote state management, create an S3 bucket and DynamoDB table:

```bash
# Create S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket streamingapp-terraform-state-prod \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket streamingapp-terraform-state-prod \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region ap-south-1
```

## Backend Configuration

Uncomment the backend configuration in `main.tf`:

```hcl
backend "s3" {
  bucket         = "streamingapp-terraform-state-prod"
  key            = "prod/terraform.tfstate"
  region         = "ap-south-1"
  encrypt        = true
  dynamodb_table = "terraform-locks"
}
```

## Initialize Terraform

```bash
terraform init
```

## Apply Configuration

### Dev Environment
```bash
terraform apply -var-file=terraform.tfvars
```

### Production Environment
```bash
terraform apply -var-file=terraform.prod.tfvars
```
