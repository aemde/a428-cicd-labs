pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/aemde/a428-cicd-labs.git'
        BRANCH = 'react-app-wsl'
        APP_DIR = 'app'
        DOCKER_COMPOSE_FILE = 'docker-compose.yml'
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
                echo 'Workspace cleaned successfully.'
            }
        }

        stage('Clone Repository') {
            steps {
                retry(3) {
                    echo "Cloning repository ${REPO_URL} (branch: ${BRANCH})..."
                    git branch: "${BRANCH}",
                        url: "${REPO_URL}"
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                dir("${APP_DIR}") {
                    sh '''
                    if ! command -v npm > /dev/null; then
                        echo "npm is not installed. Please install Node.js and npm."
                        exit 1
                    fi

                    npm config set cache ~/.npm-cache --global
                    npm cache clean --force || true
                    [ -d node_modules ] && rm -rf node_modules

                    if [ ! -f package-lock.json ]; then
                        echo "package-lock.json is missing. Running npm install..."
                        npm install --legacy-peer-deps
                    else
                        npm ci --legacy-peer-deps
                    fi
                    '''
                }
            }
        }

        stage('Run Tests') {
            steps {
                echo 'Running tests...'
                dir("${APP_DIR}") {
                    sh '''
                    if [ -f ./jenkins/scripts/test.sh ]; then
                        chmod +x ./jenkins/scripts/test.sh
                        ./jenkins/scripts/test.sh
                    else
                        echo "No test script found. Skipping tests."
                    fi
                    '''
                }
            }
        }

        stage('Build Application') {
            steps {
                echo 'Building application...'
                dir("${APP_DIR}") {
                    sh '''
                    npm run build || {
                        echo "Build failed. Stopping pipeline."
                        exit 1
                    }
                    '''
                }
            }
        }

        stage('Deploy Application') {
            steps {
                echo 'Deploying application using Docker...'
                dir("${APP_DIR}") {
                    sh '''
                    if ! command -v docker > /dev/null; then
                        echo "Docker is not installed. Please install Docker."
                        exit 1
                    fi

                    if [ ! -f docker-compose.yml ]; then
                        echo "docker-compose.yml is missing. Stopping pipeline."
                        exit 1
                    fi

                    docker-compose down || true
                    docker-compose up -d --build --force-recreate
                    '''
                }
                echo 'Deployment completed successfully. Visit your application at http://localhost:3000'
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
        }
        success {
            echo 'Build and deployment successful!'
        }
        failure {
            echo 'Build or deployment failed. Please check logs.'
        }
        cleanup {
            cleanWs()
        }
    }
}
