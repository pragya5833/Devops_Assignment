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
        stage ('Build Image'){
            steps{
                script{
                  docker.withRegistry('https://hub.docker.com/', 'dockerhub') {
                sh 'docker build -t vprof:1.0 --build-arg=WAR_ARCHIVE=vprofile-v1.war .'
                        sh 'docker tag vprof:1.0 848417356303.dkr.ecr.ap-south-1.amazonaws.com/vprof:latest'
                }
                }
            }
        }
        stage('Push'){
            steps{
                script{
                    withCredentials([[
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: "jenkins-aws",
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                        ]]){
                        sh 'aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 848417356303.dkr.ecr.ap-south-1.amazonaws.com'
                        sh 'docker push 848417356303.dkr.ecr.ap-south-1.amazonaws.com/vprof:latest'
                    }
                }
            }

        }
        stage('Deploy To Staging'){
            steps{
                withCredentials([sshUserPrivateKey(credentialsId: "94fd9ccf-c541-4cf3-b185-cb12e8c96688", keyFileVariable: 'keyfile')]){
                    sh "ssh -i ${keyfile} ec2-user@65.2.35.87 && scp ./scripts/deploy.sh /tmp/deploy.sh && ./tmp/deploy.sh"
            }
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