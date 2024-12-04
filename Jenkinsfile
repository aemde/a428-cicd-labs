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
                        def retries = 3
                        for (int i = 0; i < retries; i++) {
                            try {
                                bat '''
                                if exist C:\\app (
                                    powershell -Command "& {
                                        $lockedProcesses = Get-Process | Where-Object { $_.Path -like 'C:\\app*' };
                                        if ($lockedProcesses) {
                                            $lockedProcesses | Stop-Process -Force;
                                        }
                                        Get-Process | Out-File C:\\processes.txt;
                                        Start-Sleep -Seconds 2;
                                        Remove-Item -Recurse -Force C:\\app
                                    }"
                                ) else (
                                    echo "C:\\app does not exist, skipping removal."
                                )
                                '''
                                break
                            } catch (Exception e) {
                                echo "Failed to clean workspace attempt (${i + 1}/${retries}): ${e.message}"
                                if (i == retries - 1) {
                                    error "Failed to clean workspace after ${retries} attempts."
                                }
                                sleep(time: 10, unit: 'SECONDS')
                            }
                        }
                    }
                }
            }
        }
        stage('Clone Repository') {
            steps {
                echo 'Cloning repository...'
                script {
                    try {
                        bat 'git clone --branch react-app https://github.com/aemde/a428-cicd-labs.git /app'
                    } catch (Exception e) {
                        echo "Failed to clone repository: ${e.message}"
                        error "Stopping pipeline due to clone failure."
                    }
                }
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
                            error "Stopping pipeline due to dependency installation failure."
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
                            error "Stopping pipeline due to critical dependency installation failure."
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
                    script {
                        try {
                            bat '''
                            docker ps -q --filter "name=react-app" && docker stop react-app && docker rm react-app || echo "No react-app container found"
                            docker ps -q --filter "name=prometheus" && docker stop prometheus && docker rm prometheus || echo "No prometheus container found"
                            docker ps -q --filter "name=grafana" && docker stop grafana && docker rm grafana || echo "No grafana container found"
                            docker-compose down
                            docker-compose up -d --build --force-recreate
                            '''
                        } catch (Exception e) {
                            echo "Deployment failed: ${e.message}"
                            error "Stopping pipeline due to deployment failure."
                        }
                    }
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
