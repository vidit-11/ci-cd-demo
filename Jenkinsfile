pipeline {
    agent { label 'docker-agent' }

    environment {
        DOCKER_HUB_USER = 'vidit11'
        IMAGE_NAME      = 'java-app'
        REGISTRY        = "${DOCKER_HUB_USER}/${IMAGE_NAME}"
        CONTAINER_NAME  = "my-java-container"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Unit Tests') {
            steps {
                // Fixed permission issue by running as current user 
                sh "docker run --rm -u \$(id -u):\$(id -g) -v ${WORKSPACE}:/app -w /app maven:3.9.6-eclipse-temurin-17 mvn clean test"
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml' [cite: 5]
                }
            }
        }

        stage('Build & Scan') {
            steps {
                sh "docker build -t ${REGISTRY}:${BUILD_NUMBER} ." [cite: 6]
                sh "docker tag ${REGISTRY}:${BUILD_NUMBER} ${REGISTRY}:latest" [cite: 7]
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', 
                                                passwordVariable: 'DOCKER_HUB_PASSWORD', 
                                                usernameVariable: 'DOCKER_HUB_USERNAME')]) { [cite: 8, 9]
                    sh 'echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin' [cite: 10]
                    sh "docker push ${REGISTRY}:${BUILD_NUMBER}"
                    sh "docker push ${REGISTRY}:latest"
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh "docker rmi ${REGISTRY}:${BUILD_NUMBER} || true" [cite: 11]
                sh "docker image prune -f"
            }
        }

        stage('Deploy') {
            steps {
                // Remove old container to avoid name conflicts
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
                // Run new container in background (-d) with port mapping 8080
                sh "docker run -d --name ${CONTAINER_NAME} -p 8080:8080 ${REGISTRY}:latest"
            }
        }
    }
}
