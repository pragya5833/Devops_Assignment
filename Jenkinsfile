pipeline{
    agent { label 'docker-slave' }
    parameters {
        string(name: 'Branch', defaultValue: 'main', description: 'Branch To Build')
    }

    environment{
        project_url ='https://github.com/pragya5833/Devops_Assignment.git'
        branch_to_build="${env.GIT_BRANCH  ? "staging" : "production"}"
    }
    stages{
        stage('Clone'){
            steps{
                checkout scm: ([
                    $class: 'GitSCM',
                    userRemoteConfigs: [[credentialsId: 'b03c1955-a7a5-46ff-ac05-8ad25a8cb019',url: "${project_url}"]],
                    branches: [[name: "${env.GIT_BRANCH}"]]
            ])
            }
        }
        stage('Build'){
            steps{
                sh '''
                printenv
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
                            sh 'docker build --platform linux/amd64 --build-arg WAR_ARCHIVE=./target/vprofile-v1.war -t vprof:1.0 .'
                        sh 'docker tag vprof:1.0 848417356303.dkr.ecr.ap-south-1.amazonaws.com/vprof:latest'
                        sh 'aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 848417356303.dkr.ecr.ap-south-1.amazonaws.com'
                        sh 'docker push 848417356303.dkr.ecr.ap-south-1.amazonaws.com/vprof:latest'
                    }
                }
            }

        }
        stage('Deploy To Staging'){
            steps{
                echo 'deploying to staging'
            //     withCredentials([sshUserPrivateKey(credentialsId: "ubuntu", keyFileVariable: 'keyfile')]){
            //         sh "scp -i ${keyfile} ./scripts/deploy.sh ubuntu@3.110.62.75:/tmp/deploy.sh"
            //         sh """ssh -i ${keyfile} ubuntu@3.110.62.75 << EOF
            //                sh /tmp/deploy.sh
            //                exit
            //         EOF """
            // }
            }
        }
        stage('Deploy To Production'){
            steps{
                input id: 'Deploy', message: 'Deploy to production?', submitter: 'admin'
                echo 'deploying to prod'
            //     withCredentials([sshUserPrivateKey(credentialsId: "ubuntu", keyFileVariable: 'keyfile')]){
            //         sh "scp -i ${keyfile} ./scripts/deploy.sh ubuntu@43.205.140.225:/tmp/deploy.sh"
            //         sh """ssh -i ${keyfile} ubuntu@43.205.140.225 << EOF
            //                sh /tmp/deploy.sh
            //                exit
            //         EOF """
            // }
            //$GWBT_REF

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