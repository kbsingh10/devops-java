pipeline {
    agent any

    tools {
        jdk 'jdk-25'
        gradle 'gradle-9.1' 
    }

    stages {
        stage('Build') {
            steps {
                echo "Compiling code with Gradle..."
                sh 'gradle assemble' 
            }
        }

        stage('Test') {
            steps {
                echo "Running tests..."
                sh 'gradle test'
            }
            post {
                always {
                    junit 'build/test-results/test/*.xml'
                }
            }
        }

        stage('Package Check') {
            steps {
                echo "Archiving artifacts..."
                archiveArtifacts artifacts: 'build/libs/*.jar', fingerprint: true
            }
        }

        stage('Deploy') {
            options { timeout(time: 10, unit: 'MINUTES') }
            steps {
                echo "Simulating Demo Deployment of Gradle build..."
                sh 'echo "Deploying from build/libs/ to demo server..."'
            }
        }
    }

    post {
        always { cleanWs() }
    }
}