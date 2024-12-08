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
                                sh '''
                                if [ -d /app ]; then
                                    pkill -f '/app/*' || echo "No locked processes found."
                                    rm -rf /app || echo "Failed to remove /app"
                                else
                                    echo "/app does not exist, skipping removal."
                                fi
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
                        sh 'git clone --branch react-app https://github.com/aemde/a428-cicd-labs.git /app'
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
                sh '''
                npm config set cache /mnt/c/npm-cache --global
                npm cache clean --force
                '''
                echo 'Installing dependencies...'
                dir('/app') {
                    script {
                        try {
                            sh '''
                            if [ -d node_modules ]; then
                                rm -rf node_modules
                            fi
                            if [ ! -f package-lock.json ]; then
                                echo "package-lock.json is missing. Running npm install to generate it..."
                                npm install --legacy-peer-deps
                            else
                                npm ci --legacy-peer-deps
                            fi
                            '''
                        } catch (Exception e) {
                            echo "Failed to install dependencies: ${e.message}"
                            error "Stopping pipeline due to dependency installation failure."
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
                            sh './jenkins/scripts/test.sh'
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
                            sh '''
                            docker ps -q --filter "name=react-app" && docker stop react-app && docker rm react-app || echo "No react-app container found"
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
