pipeline{
    agent { label 'aws_agent' }
    environment{
        project_url ='https://github.com/pragya5833/Devops_Assignment.git'
    }
    // parameters {
    //     string(name: 'Branch', defaultValue: 'main', description: 'Branch To Build')
    // }
    stages{
        stage('Clone'){
            steps{
                checkout scm: ([
                    $class: 'GitSCM',
                    userRemoteConfigs: [[credentialsId: 'b03c1955-a7a5-46ff-ac05-8ad25a8cb019',url: "${project_url}"]],
                    branches: [[name: "${GIT_BRANCH}"]]
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
        stage('Push'){
            steps{
                script{
                    withCredentials([[
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: "jenkins_agent",
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
                withCredentials([sshUserPrivateKey(credentialsId: "jenkins_agent_login", keyFileVariable: 'keyfile')]){
                    sh "scp -i ${keyfile} ./scripts/deploy.sh ubuntu@13.233.85.92:/tmp/deploy.sh"
                    sh """ssh -i ${keyfile} ubuntu@13.233.85.92 << EOF
                           sh /tmp/deploy.sh
                           exit
                    EOF """
            }
            }
        }
        stage('Deploy To Production'){
            steps{
                if (${GIT_BRANCH} == 'main') {
                        input id: 'Deploy', message: 'Deploy to production?', submitter: 'admin'
                echo 'deploying to prod'
                withCredentials([sshUserPrivateKey(credentialsId: "jenkins_agent_login", keyFileVariable: 'keyfile')]){
                    sh "scp -i ${keyfile} ./scripts/deploy.sh ubuntu@43.205.207.190:/tmp/deploy.sh"
                    sh """ssh -i ${keyfile} ubuntu@43.205.207.190 << EOF
                           sh /tmp/deploy.sh
                           exit
                    EOF """
            }
                    } 
                    else {
                        echo 'No Prod deployment as its not main branch'
                    }
                

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