pipeline {
    agent {
        docker {
            image 'node:16-buster-slim'
            args '-p 3000:3000'
        }
    }
    stages {
        stage('Set NPM Registry') {
            steps {
                script {
                    sh 'npm config set registry https://registry.npm.taobao.org'
                }
            }
        }

        stage('Build') {
            steps {
                sh 'npm cache clean --force'
                sh 'npm install'
            }
        }

        stage('Test') {
            steps {
                sh './jenkins/scripts/test.sh'
            }
        }
    }
}
