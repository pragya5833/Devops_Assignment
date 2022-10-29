pipeline{
    agent { label 'docker-slave' }
    environment{
        project_url ='https://github.com/pragya5833/Devops_Assignment.git'
    }
    parameters {
        string(name: 'Branch', defaultValue: 'main', description: 'Branch To Build')
    }
    stages{
        stage('Clone'){
            steps{
                checkout scm: ([
                    $class: 'GitSCM',
                    userRemoteConfigs: [[credentialsId: 'b03c1955-a7a5-46ff-ac05-8ad25a8cb019',url: "${project_url}"]],
                    branches: [[name: "${Branch}"]]
            ])
            }
        }
        stage('Build'){
            steps{
                sh '''
                   mvn -B -DskipTests clean package
                '''
            }
        }
        stage('Test'){
            steps{
                sh 'mvn test'
            }

        }
        // stage ('Build Image'){
        //     steps{
        //         script{
        //           docker.withRegistry('http://127.0.0.1:3375', 'dockerhub') {
                
        //         }
        //         }
        //     }
        // }
        stage('Push'){
            steps{
                script{
                    withCredentials([[
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: "jenkins-aws",
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                        ]]){
                            sh 'docker build --build-arg WAR_ARCHIVE=./target/vprofile-v1.war -t vprof:1.0 .'
                        sh 'docker tag vprof:1.0 848417356303.dkr.ecr.ap-south-1.amazonaws.com/vprof:latest'
                        sh 'aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 848417356303.dkr.ecr.ap-south-1.amazonaws.com'
                        sh 'docker push 848417356303.dkr.ecr.ap-south-1.amazonaws.com/vprof:latest'
                    }
                }
            }

        }
        stage('Deploy To Staging'){
            steps{
                // withCredentials([sshUserPrivateKey(credentialsId: "94fd9ccf-c541-4cf3-b185-cb12e8c96688", keyFileVariable: 'keyfile')]){
                    sh "scp -i /Users/pragyabharti/Devops_Assignment/Devops_Assignment/xyz.pem ./scripts/deploy.sh ubuntu@3.110.62.75:/tmp/deploy.sh"
                    sh """ssh -i /Users/pragyabharti/Devops_Assignment/Devops_Assignment/xyz.pem ubuntu@3.110.62.75 << EOF
                    ./tmp/deploy.sh
                    exit
                    EOF """
            // }
            }
        }
        stage('Deploy To Production'){
            steps{
                input id: 'Deploy', message: 'Deploy to production?', submitter: 'admin'
                echo 'deploy to prod'
            }
        }
    }
    post {
                always {
                    junit 'target/surefire-reports/*.xml' 
                }
                success{
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
}