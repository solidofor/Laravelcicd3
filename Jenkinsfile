pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker')
        DOCKER_IMAGE = 'oforsolid/laravelcicd3'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/solidofor/Laravelcicd3.git'
            }
        }

        stage('Build') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:latest .'
            }
        }

        stage('Login to Docker Hub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh 'docker push $DOCKER_IMAGE:latest'
            }
        }

        stage('Trigger ArgoCD Sync') {
            steps {
                // This would trigger ArgoCD to sync with the deployment repo
                // The exact command depends on your ArgoCD setup
                sh 'echo "Image pushed to Docker Hub, ArgoCD should pick up the changes"'
            }
        }
    }

    post {
        always {
            sh 'docker logout'
        }
    }
}