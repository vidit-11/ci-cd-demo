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
                sh "docker run --rm -u \$(id -u):\$(id -g) -v ${WORKSPACE}:/app -w /app maven:3.9.6-eclipse-temurin-17 mvn clean test"
            }
            post {
                always {
                    // Add allowEmptyResults: true to stop the pipeline from crashing
                    junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                }
            }

        stage('Build & Scan') {
            steps {
                sh "docker build -t ${REGISTRY}:${BUILD_NUMBER} ."
                sh "docker tag ${REGISTRY}:${BUILD_NUMBER} ${REGISTRY}:latest"
                // Optional: Add a vulnerability scan here if you have Trivy installed
                // sh "trivy image ${REGISTRY}:${BUILD_NUMBER}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', 
                                                passwordVariable: 'DOCKER_HUB_PASSWORD', 
                                                usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                    sh 'echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin'
                    sh "docker push ${REGISTRY}:${BUILD_NUMBER}"
                    sh "docker push ${REGISTRY}:latest"
                }
            }
        }


        stage('Cleanup') {
            steps {
                sh "docker rmi ${REGISTRY}:${BUILD_NUMBER} || true"
                sh "docker image prune -f"
            }
        }
        stage('Deploy') {
                steps {
                    // Stop and remove the old container if it exists
                    sh "docker stop ${CONTAINER_NAME} || true"
                    sh "docker rm ${CONTAINER_NAME} || true"
                
                    // Run the new container in detached mode (-d) with port mapping
                    sh "docker run -d --name ${CONTAINER_NAME} -p 8080:8080 ${REGISTRY}:latest"
                }
            }
        }
    }
}
