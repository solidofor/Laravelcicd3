pipeline {
    agent { label "jenkins-build-node" }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        IMAGE_NAME = "oforsolid/laravelcicd3"
        IMAGE_TAG = "v${env.BUILD_NUMBER}"
        GITHUB_CREDENTIALS = credentials('github') 
        DEPLOYMENT_REPO = 'https://github.com/solidofor/Laravelcicd3-deploy.git'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/solidofor/laravelcicd3.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub') {
                        docker.image("${IMAGE_NAME}:${IMAGE_TAG}").push()
                    }
                }
            }
        }


        // stage('Update Manifest and Push to GitHub') {
        //     steps {
        //         script {
        //             sh """
        //                 sed -i 's|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|' laravel-deployment.yaml
        //                 git config user.name "solidofor"
        //                 git config user.email "solidofor@yahoo.com"
        //                 git remote set-url origin https://${GITHUB_CREDENTIALS_USR}:${GITHUB_CREDENTIALS_PSW}@github.com/solidofor/Laravelcicd3-deploy.git
        //                 git add laravel-deployment.yaml
        //                 git commit -m "Update image tag to ${IMAGE_TAG}  [CI]" || echo "No changes to commit"
        //                 git push origin main
        //             """
        //         }
        //     }
        

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
                            sed -i 's|${IMAGE_NAME}:.*|${IMAGE_NAME}:${IMAGE_TAG}|' laravel-deployment.yaml
                        """

                        withCredentials([usernamePassword(
                            credentialsId: 'github',
                            usernameVariable: 'GITHUB_CREDENTIALS_USR',
                            passwordVariable: 'GITHUB_CREDENTIALS_PSW'
                        )]) {
                            sh """
                                git config user.email "solidofor@yahoo.com"
                                git config user.name "solidofor"
                                git remote set-url origin https://${GITHUB_CREDENTIALS_USR}:${GITHUB_CREDENTIALS_PSW}@github.com/solidofor/Laravelcicd3-deploy.git
                                git add laravel-deployment.yaml
                                git commit -m "Update image tag to ${IMAGE_TAG} [CI]" || echo "No changes to commit"
                                git push origin main
                            """
                        }
                    }
                }
            }
        }

                                // git config user.email "solidofor@yahoo.com"
                                // git config user.name "solidofor"
                                // git add laravel-deployment.yaml
                                // git commit -m "Update image tag to ${IMAGE_TAG} [CI]" || echo "No changes to commit"
                                // git push https://${GITHUB_CREDENTIALS_USR}:${GITHUB_CREDENTIALS_PSW}@github.com/solidofor/Laravelcicd3-deploy.git
                                
                                // sed -i 's|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|' laravel-deployment.yaml
                                // git config user.name "solidofor"
                                // git config user.email "solidofor@yahoo.com"
                                // git remote set-url origin https://${GITHUB_CREDENTIALS_USR}:${GITHUB_CREDENTIALS_PSW}@github.com/solidofor/Laravelcicd3-deploy.git
                                // git add laravel-deployment.yaml
                                // git commit -m "Update image tag to ${IMAGE_TAG}  [CI]" || echo "No changes to commit"
                                // git push origin main


    }
}
