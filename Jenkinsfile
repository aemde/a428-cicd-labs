pipeline {
    agent any
    environment {
        CI = 'true'
        NODE_OPTIONS = '--openssl-legacy-provider'
    }
    stages {
        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                bat 'npm install'
            }
        }
        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                bat './jenkins/scripts/test.bat'
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
                bat 'npm run build'
                echo 'Running the application locally...'
                bat 'start /B npx serve -s build -l 3000'
                echo 'Visit http://localhost:3000 to view the application.'
                bat 'powershell -command "Start-Sleep -Seconds 60"'
                echo 'Stopping the application server...'
                bat 'taskkill /IM node.exe /F'
            }
        }
    }
}
