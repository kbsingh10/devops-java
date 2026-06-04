pipeline {
    agent { label 'slave' }

    tools {
        jdk 'jdk-17'
        gradle 'gradle-8.14'
    }

    environment {
        APP_NAME = 'calculator'
        JAR_NAME = "calculator-1.0.0.jar"
        DEPLOY_SERVER = '10.0.1.56'
        DEPLOY_USER = 'ubuntu'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building the application...'
                sh './gradlew clean compileJava'
            }
        }

        stage('Test') {
            steps {
                echo 'Running unit tests...'
                sh './gradlew test'
            }
            post {
                always {
                    junit 'build/test-results/test/*.xml'
                }
            }
        }

        stage('Package') {
            steps {
                echo 'Packaging into JAR...'
                sh './gradlew bootJar'
            }
            post {
                success {
                    archiveArtifacts artifacts: 'build/libs/*.jar', fingerprint: true
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying to app-server1 via Docker...'
                sshagent(['app-server-key']) {
                    sh """
                        # Copy JAR and Dockerfile to app-server1
                        scp -o StrictHostKeyChecking=no \
                            build/libs/${JAR_NAME} \
                            ${DEPLOY_USER}@${DEPLOY_SERVER}:~/

                        scp -o StrictHostKeyChecking=no \
                            Dockerfile \
                            ${DEPLOY_USER}@${DEPLOY_SERVER}:~/

                        # Build and run Docker container on app-server1
                        ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_SERVER} '
                            # Stop and remove old container
                            docker stop ${APP_NAME} || true
                            docker rm ${APP_NAME} || true

                            # Build new image
                            docker build -t ${APP_NAME}:latest .

                            # Run new container
                            docker run -d \
                                --name ${APP_NAME} \
                                --restart always \
                                -p 8080:8080 \
                                ${APP_NAME}:latest

                            echo "Container started successfully"
                            docker ps | grep ${APP_NAME}
                        '
                    """
                }
            }
        }

    }

    post {
        always {
            echo 'Pipeline finished.'
            cleanWs()
        }
        success {
            echo 'Build, Test, Package and Deploy completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs above.'
        }
    }
}
