pipeline {
    agent {
        docker {
            image 'node:lts-buster-slim'
            args '-u root -p 3000:3000' // Menjalankan container sebagai root dengan pemetaan port
        }
    }
    environment {
        CI = 'true' // Menetapkan variabel lingkungan CI
    }
    stages {
        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                sh '''
                npm install
                '''
            }
        }
        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                sh '''
                ./jenkins/scripts/test.sh
                '''
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
                sh '''
                ./jenkins/scripts/deliver.sh
                sleep 60
                ./jenkins/scripts/kill.sh
                '''
            }
        }
    }
}
