pipeline {
    agent {
        docker {
            image 'node:lts-buster-slim'
            args '-p 3000:3000'
        }
    }
    environment {
        CI = 'true'
    }
    stages {
        stage('Setup Environment') {
            steps {
                sh 'export PATH=$PATH:/usr/bin' // Pastikan Docker CLI tersedia di PATH
            }
        }
        stage('Build') {
            agent {
                docker {
                    image 'node:lts-buster-slim'
                    args '-u root -p 3000:3000' // Jalankan sebagai root
                }
            }
            steps {
                sh 'npm install'
            }
        }
        stage('Test') {
            steps {
                sh './jenkins/scripts/test.sh'
            }
        }
        stage('Manual Approval') {
            steps {
                input message: 'Lanjutkan ke tahap Deploy?', ok: 'Proceed'
            }
        }
        stage('Deploy') {
            steps {
                sh './jenkins/scripts/deliver.sh'
                sleep 60 // Jeda otomatis selama 1 menit
                sh './jenkins/scripts/kill.sh'
            }
        }
    }
}
