pipeline {
    agent { label 'slave' }

    tools {
        jdk 'jdk-17' // Ensure this tool is configured in Jenkins Global Tool Configuration
        gradle 'gradle-8.14'
    }

    environment {
        APP_NAME = 'calculator'
        JAR_NAME = "calculator-1.0.0.jar"
    }

    stages {
        stage('Checkout') {
            steps {
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
                    //jacoco execPattern: 'build/jacoco/test.exec',
                      //     classPattern: 'build/classes/java/main',
                      //     sourcePattern: 'src/main/java',
                      //     inclusionPattern: '**/*.class'
                }
            }
        }

        stage('Package') {
            steps {
                echo 'Packaging the application into a JAR...'
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
            echo 'Deploying to the target environment...'
            sshagent(['app-server-key']) {
            sh """
                scp -o StrictHostKeyChecking=no \
                    build/libs/${JAR_NAME} \
                    ubuntu@10.0.1.56:~/
            """
        }
        echo 'Deployment successful.'
    }
 }
    }

    post {
        always {
            echo 'Pipeline finished execution.'
        }
        success {
            echo 'Build, Test, Package, and Deploy stages completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs for more information.'
        }
    }
}