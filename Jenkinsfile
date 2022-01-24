#!groovy
pipeline {
    agent any

    environment {
        COMMIT_HASH = sh(returnStdout: true, script: "git rev-parse --short=8 HEAD").trim()
        AWS_REGION = sh(script:'aws configure get region', returnStdout: true).trim()
        AWS_ACCOUNT_ID = sh(script:'aws sts get-caller-identity --query "Account" --output text', returnStdout: true).trim()
        ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        PROJECT_ID  = "AB"

        image_label = "flights-microservice-${PROJECT_ID.toLowerCase()}"
        image = null
        packaged = false
        built = false
    }

    stages {
        stage('Package') {
            steps {
                sh "./mvnw package"
                sh "docker context use default"
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}"
            }

            post {
                success {
                    script {
                        packaged = true
                    }
                }
            }
        }

        //stage('SonarQube Analysis') {
        //    steps {
        //        withSonarQubeEnv('SonarQube') {
        //            sh './mvnw org.sonarsource.scanner.maven:sonar-maven-plugin:3.7.0.1746:sonar'
        //        }
        //    }
        //}

        stage('Build') {
            steps {
                script {
                    image = docker.build(image_label)
                }
            }

            post {
                success {
                    script {
                        built = true
                    }
                }
            }
        }

        stage('Push to registry') {
            steps {
                script {
                    docker.withRegistry("$ECR_URI/$image_label", "ecr:$AWS_REGION:ecr-creds") {
                        image.push("$COMMIT_HASH")
                        image.push('latest')
                    }
                }
            }
        }
    }

    post {
        cleanup {
            script {
                if(packaged) {
                    sh "./mvnw clean"

                    if(built) {
                        sh "docker rmi $image_label"
                    }
                }
            }
        }
    }
}



