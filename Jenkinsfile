pipeline {

    agent { docker { image 'golang:1.22.1-alpine3.19' } }

    environment {
        registry = "awodi2525/img-http-echo"
        registeryCredential = 'dockerhub'
    }

    stages{

        stage('BUILD'){
            steps {
                sh 'go version' 
            }
        }
    }

    stage('Build App Image'){
        steps {
            script {
                dockerImage = docker.build registry + ":V$BUILD_NUMBER"
            }
        }
    }

    stage('Upload Image'){
        steps{
            script {
               docker.withDockerRegistry('', registeryCredential) {
                docker.Image.push("V$BUILD_NUMBER")
                docker.Image.push("latest")
               }
            }
        }
    }

    stage('Remove Unused docker image'){
        steps{
            sh "docker rmi $registry:V$BUILD_NUMBER"
        }
    }

    stage('Kubernetes Deploy') {
        steps {
            sh "helm upgrade --install http-echo-release ./helm-http-echo --set image.repository=awodi2525/img-http-echo --set image.tag=latest"
        }
    }
}
//