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
                bat '''
                npm install
                '''
            }
        }
        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                bat '''
                call jenkins\\scripts\\test.bat
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
                bat '''
                call jenkins\\scripts\\deliver.bat
                timeout /t 60
                call jenkins\\scripts\\kill.bat
                '''
            }
        }
    }
}
