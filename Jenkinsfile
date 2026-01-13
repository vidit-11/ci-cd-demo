pipeline {
    agent { label 'docker-agent' } // This forces the job onto your EC2 Slave

    environment {
        // Change these to your actual Docker Hub details
        DOCKER_HUB_USER = 'vidit11'
        IMAGE_NAME      = 'java-app'
        REGISTRY        = "${DOCKER_HUB_USER}/${IMAGE_NAME}"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                // Pulls code from the main branch
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Triggers the multi-stage build defined in the Dockerfile
                    sh "docker build -t ${REGISTRY}:${BUILD_NUMBER} ."
                    sh "docker tag ${REGISTRY}:${BUILD_NUMBER} ${REGISTRY}:latest"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                // Uses the 'docker-hub-creds' you saved in Jenkins Credentials
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', 
                                                passwordVariable: 'DOCKER_HUB_PASSWORD', 
                                                usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                    
                    sh "echo ${DOCKER_HUB_PASSWORD} | docker login -u ${DOCKER_HUB_USERNAME} --password-stdin"
                    
                    echo "Pushing Image to Docker Hub..."
                    sh "docker push ${REGISTRY}:${BUILD_NUMBER}"
                    sh "docker push ${REGISTRY}:latest"
                }
            }
        }

        stage('Cleanup') {
            steps {
                // Important for t2.micro to save disk space
                sh "docker rmi ${REGISTRY}:${BUILD_NUMBER} ${REGISTRY}:latest"
                sh "docker image prune -f"
            }
        }
    }
}
