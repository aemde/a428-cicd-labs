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
                    script {
                        try {
                            // Attempt to delete directory using PowerShell to handle locked files
                            bat '''
                            if exist C:\\app (
                                powershell -Command "Start-Sleep -Seconds 2; Remove-Item -Recurse -Force C:\\app"
                            ) else (
                                echo "C:\\app does not exist, skipping removal."
                            )
                            '''
                        } catch (Exception e) {
                            echo "Failed to clean workspace: ${e.message}"
                        }
                    }
                }
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
                echo 'Setting npm cache directory...'
                bat '''
                npm config set cache C:\\npm-cache --global
                npm cache clean --force
                '''

                echo 'Installing dependencies...'
                dir('/app') {
                    script {
                        try {
                            bat '''
                            if exist node_modules (
                                powershell -Command "Remove-Item -Recurse -Force node_modules"
                            )
                            if not exist package-lock.json (
                                echo "package-lock.json is missing. Running npm install to generate it..."
                                npm install --legacy-peer-deps
                            ) else (
                                npm ci --legacy-peer-deps
                            )
                            '''
                        } catch (Exception e) {
                            echo "Failed to install dependencies: ${e.message}"
                        }
                    }
                }

                echo 'Verifying critical dependencies...'
                dir('/app') {
                    script {
                        try {
                            bat '''
                            npm install tr46 --save-dev
                            npm install extglob --save-dev
                            npm install --legacy-peer-deps
                            '''
                        } catch (Exception e) {
                            echo "Failed to install critical dependencies: ${e.message}"
                        }
                    }
                }
            }
        }
        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                dir('/app') {
                    script {
                        try {
                            bat './jenkins/scripts/test.bat'
                        } catch (Exception e) {
                            echo "Tests failed: ${e.message}"
                            error "Stopping pipeline due to test failures."
                        }
                    }
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
            script {
                try {
                    echo 'Cleaning workspace...'
                    cleanWs()
                } catch (Exception e) {
                    echo "Failed to clean workspace: ${e.message}"
                }
            }
        }
    }
}
