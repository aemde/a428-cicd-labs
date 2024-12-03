pipeline {
    agent any
    environment {
        CI = 'true'
        NODE_OPTIONS = '--openssl-legacy-provider'
    }
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning repository...'
                bat '''
                git clone --branch react-app https://github.com/aemde/a428-cicd-labs.git /app
                '''
            }
        }
        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                dir('/app') {
                    bat 'npm install'
                }
            }
        }
        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                dir('/app') {
                    bat './jenkins/scripts/test.bat'
                }
            }
        }
        stage('Manual Approval') {
            steps {
                input message: 'Proceed to deploy?', ok: 'Yes'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                dir('/app') {
                    bat '''
                    docker ps -q --filter "name=prometheus" && docker stop prometheus && docker rm prometheus || echo "No existing prometheus container"
                    docker ps -q --filter "name=grafana" && docker stop grafana && docker rm grafana || echo "No existing grafana container"
                    docker-compose down
                    docker-compose up -d --build
                    '''
                }
                echo 'Visit http://localhost:3000 to view the application.'
            }
        }
    }
}
