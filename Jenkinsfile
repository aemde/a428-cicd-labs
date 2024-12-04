pipeline {
    agent any
    environment {
        CI = 'true'
        NODE_OPTIONS = '--openssl-legacy-provider'
    }
    stages {
        stage('Clean Workspace') {
            steps {
                echo 'Cleaning up existing workspace...'
                dir('/app') {
                    deleteDir() // Hapus semua file di direktori workspace
                }
                bat '''
                if exist C:\\app (
                    rmdir /S /Q "C:\\app"
                ) else (
                    echo "C:\\app does not exist, skipping removal."
                )
                if exist C:\\app\\node_modules (
                    rmdir /S /Q "C:\\app\\node_modules"
                ) else (
                    echo "C:\\app\\node_modules does not exist, skipping removal."
                )
                '''
            }
        }
        stage('Clone Repository') {
            steps {
                echo 'Cloning repository...'
                bat 'git clone --branch react-app https://github.com/aemde/a428-cicd-labs.git /app'
            }
        }
        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                dir('/app') {
                    bat '''
                    if exist node_modules (
                        rmdir /S /Q "node_modules"
                    )
                    npm ci
                    '''
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
                    docker ps -q --filter "name=react-app" && docker stop react-app && docker rm react-app || echo "No react-app container found"
                    docker ps -q --filter "name=prometheus" && docker stop prometheus && docker rm prometheus || echo "No prometheus container found"
                    docker ps -q --filter "name=grafana" && docker stop grafana && docker rm grafana || echo "No grafana container found"
                    docker-compose down
                    docker-compose up -d --build --force-recreate
                    '''
                }
                echo 'Visit http://localhost:3000 to view the application.'
            }
        }
    }
    post {
        cleanup {
            cleanWs() // Bersihkan workspace setelah pipeline selesai
        }
    }
}
