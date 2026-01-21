pipeline {
    agent { label 'docker-agent' }

    environment {
        DOCKER_HUB_USER = 'vidit11'
        IMAGE_NAME      = 'iot-combined-app'
        REGISTRY        = "${DOCKER_HUB_USER}/${IMAGE_NAME}"
        CONTAINER_NAME  = "iot-app-container"
    }

    stages {
        stage('Cleanup Workspace') {
            steps {
                // Clear old root-owned files
                deleteDir()
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Package JAR') {
            steps {
                // Fix permission and npm cache errors by mounting a local home and cache
                sh """
                    docker run --rm \
                    -u \$(id -u):\$(id -g) \
                    -m 512m \
                    -e npm_config_cache=/app/.npm \
                    -v ${WORKSPACE}:/app \
                    -w /app \
                    maven:3.9.6-eclipse-temurin-17 \
                    mvn clean package -DskipTests -Duser.home=/app
                """
            }
        }

        stage('Docker Build & Push') {
            steps {
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
                // Run the single JAR container
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
                sh "docker run -d --name ${CONTAINER_NAME} -p 8080:8080 ${REGISTRY}:latest"
                sh "docker image prune -f"
            }
        }
    }
}
