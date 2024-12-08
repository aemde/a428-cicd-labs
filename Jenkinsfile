pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/aemde/a428-cicd-labs.git'
        BRANCH = 'react-app-wsl'
        APP_DIR = 'app'
        DOCKER_COMPOSE_FILE = '../docker-compose.yml'
        NVM_DIR = '/root/.nvm' // Hardcoded path to nvm
        NODE_VERSION = '18.20.5'
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

        stage('Verify Node.js and npm') {
            steps {
                sh '''
                echo "Initializing NVM..."
                export NVM_DIR="${NVM_DIR}"
                [ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh" || {
                    echo "NVM is not available. Please ensure it is installed and sourced correctly.";
                    exit 1;
                }

                echo "Using Node.js version ${NODE_VERSION}..."
                nvm install ${NODE_VERSION}
                nvm use ${NODE_VERSION} || {
                    echo "Failed to switch to Node.js version ${NODE_VERSION}.";
                    exit 1;
                }

                echo "Checking Node.js and npm versions..."
                echo "Node.js version:"
                node -v || echo "Node.js is not available."
                echo "npm version:"
                npm -v || echo "npm is not available."
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                dir("${APP_DIR}") {
                    sh '''
                    echo "Initializing NVM..."
                    export NVM_DIR="${NVM_DIR}"
                    [ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh" || {
                        echo "NVM is not available. Please ensure it is installed and sourced correctly.";
                        exit 1;
                    }
                    nvm use ${NODE_VERSION}

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
                    echo "Initializing NVM..."
                    export NVM_DIR="$HOME/.nvm"
                    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" || {
                        echo "NVM is not available. Stopping pipeline.";
                        exit 1;
                    }
                    nvm use ${NODE_VERSION} || {
                        echo "Failed to switch to Node.js version ${NODE_VERSION}. Stopping pipeline.";
                        exit 1;
                    }
                    echo "Node.js version: $(node -v)"
                    echo "NPM version: $(npm -v)"
                    # Set NODE_OPTIONS for OpenSSL compatibility
                    export NODE_OPTIONS=--openssl-legacy-provider
                    npm run build || {
                        echo "Build failed. Stopping pipeline.";
                        exit 1;
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
                    echo "Current directory: $(pwd)"
                    echo "Files in directory:"
                    ls -la
                    if [ ! -f ${DOCKER_COMPOSE_FILE} ]; then
                        echo "${DOCKER_COMPOSE_FILE} is missing. Stopping pipeline.";
                        exit 1;
                    fi

                    docker-compose -f ${DOCKER_COMPOSE_FILE} down || true
                    docker-compose -f ${DOCKER_COMPOSE_FILE} up -d --build --force-recreate
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
