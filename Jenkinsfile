pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                // Checkout code from your version control system (e.g., Git)
                git 'https://github.com/Awodi-Emmanuel/http-echo.git'
                // Build your Go application
                sh 'go build -o http-echo .'
            }
        }
        
        stage('Dockerize') {
            steps {
                // Build Docker image
                sh 'docker build -t awodi2525/http-echo:latest .'
                // Push Docker image to registry
                sh 'docker push awodi2525/http-echo:latest'
            }
        }
        
        stage('Deploy') {
            steps {
                // Deploy using Helm
                script {
                    // Add Helm repository if necessary
                    sh 'helm repo add stable https://charts.helm.sh/stable'
                    // Install or upgrade Helm chart
                    sh 'helm upgrade --install http-echo ./http-echo-chart --set image.repository=myregistry/myapp,image.tag=latest'
                }
            }
        }
    }
}