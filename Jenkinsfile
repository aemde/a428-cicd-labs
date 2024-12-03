pipeline {
    agent any
    environment {
        CI = 'true'
    }
    stages {
        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                // Gunakan 'bat' jika di Windows atau 'sh' jika di Linux/Git Bash
                bat 'npm install'
            }
        }
        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                // Ganti dengan 'bat' jika skrip adalah file .bat di Windows
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
                // Gunakan 'bat' jika di Windows atau 'sh' jika di Linux/Git Bash
                bat '''
                npm run build
                xcopy build\\* "C:\\path\\to\\deployment\\directory" /s /e /y
                timeout /t 60
                '''
            }
        }
    }
}
