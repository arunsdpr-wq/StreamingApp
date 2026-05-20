pipeline {
    agent any

    environment {

        AWS_REGION = 'ap-south-1'
        ACCOUNT_ID = '130961287799'

        ADMIN_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/admin-service"

        AUTH_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/auth-service"

        CHAT_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/chat-service"

        STREAM_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/streaming-service"

        FRONTEND_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/streaming-frontend"
    }

    stages {

        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/arunsdpr-wq/StreamingApp.git'
                }
            }

        stage('Build Docker Images') {
            steps {

                sh 'docker build -t admin-service ./backend/adminService'

                sh 'docker build -t auth-service ./backend/authService'

                sh 'docker build -t chat-service ./backend/chatService'

                sh 'docker build -t streaming-service ./backend/streamingService'

                sh 'docker build -t streaming-frontend ./frontend'

                echo "docker images built successfully"
            }
        }

        stage('Login to ECR') {
            steps {

                sh ' aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com '
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

                echo "docker images pushed successfully"
            }
        }
    }
}