pipeline {
    agent any
    
    environment {
        registry = "awodi2525/img-http-echo"
        registryCredential = 'dockerhub'
    }

    stages {
        stage('BUILD') {
            steps {
                sh 'go version'
            }
        }
        

        stage('Build App Image') {
            steps {
                script {
                    dockerImage = docker.build(registry)
                }
            }
        }

        stage('Upload Image') {
            steps {
                script {
                    docker.withRegistry('', registryCredential) {
                        dockerImage.push("V$BUILD_NUMBER")
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('Remove Unused docker image') {
            steps {
                sh "docker rmi $registry:V$BUILD_NUMBER"
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                sh "helm upgrade --install http-echo-release ./helm-http-echo --set image.repository=awodi2525/img-http-echo --set image.tag=latest"
            }
        }
    }
}
