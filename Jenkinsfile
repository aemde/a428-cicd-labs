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
                sh '''
                    git clone --branch react-app https://github.com/aemde/a428-cicd-labs.git /app
                '''
            }
        }
        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                dir('/app') {
                    sh 'npm install'
                }
            }
        }
        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                dir('/app') {
                    sh './jenkins/scripts/test.sh'
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
                    sh 'docker-compose down' // Hentikan container jika ada
                    sh 'docker-compose up -d --build' // Bangun dan jalankan container
                }
                echo 'Visit http://localhost:3000 to view the application.'
            }
        }
    }
}
