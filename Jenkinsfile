pipeline {
    agent { label 'docker-agent' }

    environment {
        DOCKER_HUB_USER = 'vidit11'
        IMAGE_NAME      = 'iot-combined-app'
        REGISTRY        = "${DOCKER_HUB_USER}/${IMAGE_NAME}"
        CONTAINER_NAME  = "iot-app-container"
    }

    stages {
        stage('Cleanup & Checkout') {
            steps {
                deleteDir()
                checkout scm
            }
        }

        stage('Docker Build & Push') {
            steps {
                // The Dockerfile handles the React and Maven builds internally
                sh "docker build --no-cache -t ${REGISTRY}:latest ."
                
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', 
                                                 passwordVariable: 'PASS', 
                                                 usernameVariable: 'USER')]) {
                    sh "echo \$PASS | docker login -u \$USER --password-stdin"
                    sh "docker push ${REGISTRY}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                sh """
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    docker run -d --name ${CONTAINER_NAME} -p 8080:8080 ${REGISTRY}:latest
                    docker image prune -f
                """
            }
        }
    }
}
