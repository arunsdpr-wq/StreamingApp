# ECR Repository - Auth Service
resource "aws_ecr_repository" "auth" {
  count                = var.enable_ecr_repositories ? 1 : 0
  name                 = "${var.project_name}-auth-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project_name}-auth-service"
  }
}

# ECR Repository - Streaming Service
resource "aws_ecr_repository" "streaming" {
  count                = var.enable_ecr_repositories ? 1 : 0
  name                 = "${var.project_name}-streaming-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project_name}-streaming-service"
  }
}

# ECR Repository - Admin Service
resource "aws_ecr_repository" "admin" {
  count                = var.enable_ecr_repositories ? 1 : 0
  name                 = "${var.project_name}-admin-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project_name}-admin-service"
  }
}

# ECR Repository - Chat Service
resource "aws_ecr_repository" "chat" {
  count                = var.enable_ecr_repositories ? 1 : 0
  name                 = "${var.project_name}-chat-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project_name}-chat-service"
  }
}

# ECR Repository - Frontend
resource "aws_ecr_repository" "frontend" {
  count                = var.enable_ecr_repositories ? 1 : 0
  name                 = "${var.project_name}-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project_name}-frontend"
  }
}

# ECR Lifecycle Policy - Keep last 10 images
resource "aws_ecr_lifecycle_policy" "default" {
  count          = var.enable_ecr_repositories ? 5 : 0
  repository     = [
    aws_ecr_repository.auth[0].name,
    aws_ecr_repository.streaming[0].name,
    aws_ecr_repository.admin[0].name,
    aws_ecr_repository.chat[0].name,
    aws_ecr_repository.frontend[0].name
  ][count.index]

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
