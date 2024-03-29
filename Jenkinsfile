pipeline {
    agent any
    
        // Ensure the desired Go version is installed for all stages,
    // using the name defined in the Global Tool Configuration
    tools { go 'go1.22' }
    
    environment {
        registry = "awodi2525/img-http-echo"
        registryCredential = 'dockerhub'
    }

    stages {
        // stage('BUILD') {
        //     steps {
        //         // Output will be something like "go version go1.19 darwin/arm64"
        //         sh 'go version'
        //     }
        // }
        

        // stage('Build App Image') {
        //     steps {
        //         script {
        //             dockerImage = docker.build(registry + ":V$BUILD_NUMBER")
        //         }
        //     }
        // }

        // stage('Upload Image') {
        //     steps {
        //         script {
        //             docker.withRegistry('', registryCredential) {
        //                 dockerImage.push("V$BUILD_NUMBER")
        //                 dockerImage.push("latest")
        //             }
        //         }
        //     }
        // }
        
        // stage('Remove Unused docker image') {
        //     steps {
        //         sh "docker rmi $registry:V$BUILD_NUMBER"
        //     }
        // }

        stage('Kubernetes Deploy') {
            steps {
                // sh "helm upgrade --install http-echo-release ./helm-http-echo --set image.repository=awodi2525/img-http-echo --set image.tag=latest"
                // sh "helm upgrade --install http-echo-release ./helm-http-echo \
                //     --wait --timeout 600s -f ./helm-http-echo/values.yaml \
                //     --set image.repository=awodi2525/img-http-echo \
                //     --set image.tag=latest \
                //     --set rbac.create=true \
                //     --set serviceAccount.name=jenkins-sa \
                //     --namespace=jenkins-agent"
                sh "kubectlb get pods"
            }
        }
    }
}
