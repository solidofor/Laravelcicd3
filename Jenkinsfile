pipeline {
    agent { label "jenkins-build-node" }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker')
        GITHUB_CREDENTIALS = credentials('github')
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
                    sh "docker build -t ${DOCKER_IMAGE}:${COMMIT_SHA} -t ${DOCKER_IMAGE}:latest ."
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    sh "docker push ${DOCKER_IMAGE}:${COMMIT_SHA}"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Update Deployment Manifest') {
            steps {
                script {
                    dir('deployment') {
                        git(
                            url: DEPLOYMENT_REPO,
                            credentialsId: 'github',
                            branch: 'main'
                        )

                        sh """
                            sed -i 's|${DOCKER_IMAGE}:.*|${DOCKER_IMAGE}:${COMMIT_SHA}|' laravel-deployment.yaml
                        """

                        withCredentials([usernamePassword(
                            credentialsId: 'github',
                            usernameVariable: 'GIT_USERNAME',
                            passwordVariable: 'GIT_PASSWORD'
                        )]) {
                            sh """
                                git config user.email "solidofor@yahoo.com"
                                git config user.name "solidofor"
                                git add laravel-deployment.yaml
                                git commit -m "Update image to ${COMMIT_SHA} [CI]" || echo "No changes to commit"
                                git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/solidofor/Laravelcicd3-deploy.git HEAD:main
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            node("jenkins-build-node") {
                script {
                    sh 'docker logout'
                }
                cleanWs()
            }
        }
        success {
            script {
                slackSend(color: 'good', message: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
            }
        }
        failure {
            script {
                slackSend(color: 'danger', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
            }
        }
    }
}
