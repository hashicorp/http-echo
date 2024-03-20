
pipeline {
    agent any
    
    environment {
        // Set environment variables for authentication (replace with your registry credentials)
        DOCKER_REGISTRY_CREDENTIALS = credentials('awodi2525')
        DOCKER_REGISTRY_URL = '192.168.156.114:9090' // Docker Desktop's local registry URL
    }
    
    stages {
        stage('Build Go Application') {
            steps {
                // Checkout the source code from your Git repository
                git 'https://github.com/Awodi-Emmanuel/http-echo.git'
                
                // Build the Go application
                sh 'go build -o http-echo .'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Use Dockerfile to build image
                    docker.build("${DOCKER_REGISTRY_URL}/http-echo:latest", '-f Dockerfile .')
                }
            }
        }
        
        stage('Push Docker Image to Local Registry') {
            steps {
                script {
                    // Tag the Docker image for the local registry
                    docker.image("${DOCKER_REGISTRY_URL}/http-echo:latest").withPush(true)
                }
            }
        }
    }
}
