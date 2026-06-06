pipeline {
    agent any

    tools {
        jdk 'jdk-17'
        gradle 'gradle-8.14'
    }

    environment {
        APP_NAME = 'calculator'
        JAR_NAME = "calculator-1.0.0.jar"
        APP_SERVER = "18.205.243.48"
    }

    stages {

        stage('Build') {
            steps {
                echo 'Building the application...'
                sh 'gradle clean compileJava'
            }
        }

        stage('Test') {
            steps {
                echo 'Running unit tests...'
                sh 'gradle test'
            }
            post {
                always {
                    junit 'build/test-results/test/*.xml'
                }
            }
        }

        stage('Package') {
            steps {
                echo 'Packaging the application into a JAR...'
                sh 'gradle bootJar'
            }
            post {
                success {
                    archiveArtifacts artifacts: 'build/libs/*.jar', fingerprint: true
                }
            }
        }

        // stage('Approval') {
        //     steps {
        //         input message: 'Approve deployment to Production?', ok: 'Deploy'
        //     }
        // }

        stage('Deploy') {
            steps {
                echo 'Deploying to server...'

                script {
                    withCredentials([sshUserPrivateKey(
                        credentialsId: 'app-server-key',
                        keyFileVariable: 'SSH_KEY'
                    )]) {

                        // 1. Upload using strict paths
                        sh """
                            set -e
                            echo "Copying JAR to server..."
                            scp -i ${SSH_KEY} -o StrictHostKeyChecking=no \
                            build/libs/${JAR_NAME} ubuntu@${APP_SERVER}:/home/ubuntu/calculator.jar.new
                        """

                        // 2. Separate string execution to prevent Here-Doc formatting chaos
                        def remoteCommands = """
                            set -e
                            echo "Deploying on remote server..."
                            
                            cd /home/ubuntu

                            if [ -f calculator.jar ]; then
                                cp calculator.jar calculator.jar.bak
                            fi

                            # Explicitly move the fresh jar into place
                            mv calculator.jar.new calculator.jar

                            echo "Restarting application service..."
                            sudo systemctl restart calculator.service

                            echo "Waiting 8 seconds for Java application boot-up validation..."
                            sleep 8

                            # If it crashes during startup, this status call will fail and break the pipeline
                            sudo systemctl status calculator.service --no-pager -l
                        """

                        sh "ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ubuntu@${APP_SERVER} \"${remoteCommands}\""
                    }
                }
                echo 'Deployment stage finished.'
            }
        }

    post {
        always {
            echo 'Pipeline finished execution.'
        }
        success {
            echo 'Build, Test, Package, Deploy completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs.'
        }
    }
}
