pipeline {
    agent any

    tools {
        // Ensures JDK is available. Match the name to what is configured 
        // in your Jenkins global tool configuration (e.g., 'JDK17' or 'JDK21')
        jdk 'jdk21'
        gradle 'gradle-814'
    }

    environment {
        // Sets a dedicated home for Gradle to enable dependency caching across builds
        GRADLE_USER_HOME = "${WORKSPACE}/.gradle"
    }

    stages {
        // stage('Checkout') {
        //     steps {
        //         // Pulls the code from source control
        //         checkout scm
        //     }
        // }

        stage('Grant Execute Permissions') {
            steps {
                // Ensures the Jenkins agent can run the wrapper script
                sh 'chmod +x gradlew'
            }
        }

        stage('Linter & Formatting') {
            steps {
                // Optional but highly recommended: checks format before compilation
                println "Checking code quality..."
                // sh './gradlew checkstyleMain' (uncomment if you use checkstyle)
            }
        }

        stage('Test') {
            steps {
                echo 'Running Unit Tests...'
                sh './gradlew test'
            }
            post {
                always {
                    // Automatically grabs JUnit test results and displays them in Jenkins UI
                    junit '**/build/test-results/test/*.xml'
                }
            }
        }

        stage('Build & Package') {
            steps {
                echo 'Compiling and packaging application into a JAR...'
                // 'bootJar' for Spring Boot apps, or 'jar'/'build' for standard Java apps
                sh './gradlew bootJar' 
            }
        }

        stage('Archive Artifacts') {
            steps {
                echo 'Archiving the built JAR file...'
                // Captures the generated JAR so it can be downloaded directly from the Jenkins UI
                archiveArtifacts artifacts: 'build/libs/*.jar', allowEmptyArchive: false
            }
        }
    }

    post {
        success {
            echo 'Pipeline successfully completed!'
        }
        failure {
            echo 'Pipeline failed. Check the logs above to debug.'
        }
    }
}