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
                    userRemoteConfigs: [[credentialsId: 'b03c1955-a7a5-46ff-ac05-8ad25a8cb019',url: ${project_url}]],
                    branches: [[name: ${Branch}]]
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
        stage('Push'){
            steps{
                sh ''
            }

        }
        stage('Deploy To Staging'){
            steps{
                sh 'echo "deploy to staging"'
            }
        }
        stage('Deploy To Production'){
            steps{
                input id: 'Deploy', message: 'Deploy to production?', submitter: 'admin'
                echo 'deploy to prod'
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
}