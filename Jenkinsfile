pipeline {
    agent any

    environment {
        DOCKER_USER = 'cesarlinares924'
        STUDENT_CODE = '202019409'
        IMAGE_NAME = "${DOCKER_USER}/retail-store-${STUDENT_CODE}"
        IMAGE_TAG = "${BUILD_NUMBER}"
        SONAR_PROJECT_KEY = "retail-store-${STUDENT_CODE}"
    }

    stages {
        stage('1. Checkout') {
            steps {
                checkout scm
            }
        }

        stage('2. Build & Unit Tests') {
            steps {
                // Evita errores de salto de línea Windows (CRLF) y permisos en mvnw
                sh 'sed -i "s/\\r$//" mvnw || true'
                sh 'chmod +x mvnw'
                sh './mvnw clean test'
            }
        }

        stage('3. SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarQubeScanner' // Verifica este nombre en Jenkins > Tools
                    withSonarQubeEnv('SonarQubeServer') {    // Verifica este nombre en Jenkins > System
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                            -Dsonar.projectName=retail-store-${STUDENT_CODE} \
                            -Dsonar.sources=src/main/java \
                            -Dsonar.tests=src/test/java \
                            -Dsonar.java.binaries=target/classes \
                            -Dsonar.java.test.binaries=target/test-classes
                        """
                    }
                }
            }
        }

        stage('4. Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('5. Docker Build') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
                }
            }
        }

        stage('6. Docker Push') {
            steps {
                script {
                    withCredentials([usernamePassword(
                            credentialsId: 'dockerhub-credentials',
                            usernameVariable: 'DOCKER_HUB_USER',
                            passwordVariable: 'DOCKER_HUB_PASS'
                    )]) {
                        sh 'echo $DOCKER_HUB_PASS | docker login -u $DOCKER_HUB_USER --password-stdin'
                        sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                        sh "docker push ${IMAGE_NAME}:latest"
                    }
                }
            }
        }

        stage('7. Run Local Container') {
            steps {
                script {
                    sh "docker rm -f retail-store-${STUDENT_CODE} || true"
                    sh "docker run -d --name retail-store-${STUDENT_CODE} -p 8080:8080 ${IMAGE_NAME}:latest"
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}