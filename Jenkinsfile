pipeline {
    agent any // Menjalankan pipeline di agent mana pun

    environment {
        REPO_URL = 'https://github.com/aemde/a428-cicd-labs.git'
        BRANCH = 'react-app-wsl'
        APP_DIR = 'app' // Nama direktori kerja
        DOCKER_COMPOSE_FILE = 'docker-compose.yml' // File docker-compose
    }

    options {
        timestamps() // Tambahkan timestamp di log
        disableConcurrentBuilds() // Hindari build bersamaan
        buildDiscarder(logRotator(numToKeepStr: '10')) // Simpan hanya 10 build terakhir
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs() // Gunakan plugin workspace cleanup
                echo 'Workspace cleaned successfully.'
            }
        }

        stage('Clone Repository') {
            steps {
                echo "Cloning repository ${REPO_URL} (branch: ${BRANCH})..."
                git branch: "${BRANCH}",
                    url: "${REPO_URL}"
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                dir("${APP_DIR}") {
                    sh '''
                    # Bersihkan cache npm jika diperlukan
                    npm config set cache ~/.npm-cache --global
                    npm cache clean --force || true

                    # Hapus folder node_modules jika ada
                    [ -d node_modules ] && rm -rf node_modules

                    # Instal dependencies
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
                    # Jalankan script testing
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
                    # Hentikan container lama
                    docker-compose down || true

                    # Jalankan container baru
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
            cleanWs() // Pastikan workspace dibersihkan setelah pipeline selesai
        }
    }
}
