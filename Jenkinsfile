pipeline {
    agent {label "jenkins-build-node"}

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker')
        GITHUB_CREDENTIALS = credentials('github')
		ARGOCD_TOKEN = credentials('argocd-api-token')
        DOCKER_IMAGE = 'oforsolid/laravelcicd3'
        DEPLOYMENT_REPO = 'https://github.com/solidofor/Laravelcicd3-deploy.git'
        COMMIT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build with commit SHA as tag
                    sh "docker build -t ${DOCKER_IMAGE}:${COMMIT_SHA} -t ${DOCKER_IMAGE}:latest ."
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    // Push both tags
                    sh "docker push ${DOCKER_IMAGE}:${COMMIT_SHA}"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Update Deployment Manifest') {
            steps {
                script {
                    // Clone deployment repo
                    dir('deployment') {
                        git(
                            url: DEPLOYMENT_REPO,
                            credentialsId: 'github',
                            branch: 'main'
                        )

                        // Update image tag in deployment manifest
                        sh """
                            sed -i 's|${DOCKER_IMAGE}:.*|${DOCKER_IMAGE}:${COMMIT_SHA}|' laravel-deployment.yaml
                        """

                        // Commit and push changes
                        withCredentials([usernamePassword(
                            credentialsId: 'github',
                            usernameVariable: 'GIT_USERNAME',
                            passwordVariable: 'GIT_PASSWORD'
                        )]) {
                            sh """
                                git config user.email "solidofor@yahoo.com"
                                git config user.name "solidofor"
                                git add laravel-deployment.yaml
                                git commit -m "Update image to ${COMMIT_SHA} [CI]"
                                git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/solidofor/Laravelcicd3-deploy.git HEAD:main
                            """
                        }
                    }
                }
            }
        }

        stage('Trigger ArgoCD Sync') {
            steps {
                script {
                    // If you have ArgoCD CLI installed on Jenkins
                    sh """
                        argocd app sync laravelcicd3
                        argocd app wait laravelcicd3 --health
                    """
                    
                    // Alternative: Use curl if you have ArgoCD API access
                    // sh 'curl -X POST -k -H "Authorization: Bearer $ARGOCD_TOKEN" https://10.0.0.22/api/v1/applications/laravelcicd3/sync'
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout'
            cleanWs()
        }
        success {
            slackSend(color: 'good', message: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
        failure {
            slackSend(color: 'danger', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
    }
}