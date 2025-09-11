pipeline {
    agent {
        docker {
            image 'node:18-bullseye'   // Debian-based image with apt
            args '-u root'             // run as root so you can install
        }
    }

    tools {
        nodejs 'NodeJS'
    }

    environment {
        SONAR_TOKEN = credentials('sonar-token')
        AMPLIFY_APP_ID = credentials('amplify-app-id')
        AWS_CREDENTIALS = 'aws-jenkins'
        S3_BUCKET = 'lambdafunctionartifacts3'
        REGION = 'ap-south-1'
    }

    stages {
        stage('Setup Tools') {
            steps {
                sh '''
                  apt-get update
                  apt-get install -y zip awscli
                '''
            }
        }

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/saadactin/react_app.git',
                    credentialsId: 'github-credentials'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build React Vite') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Run SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                    npx sonar-scanner \
                        -Dsonar.projectKey=ReactApp \
                        -Dsonar.sources=src \
                        -Dsonar.host.url=http://host.docker.internal:9000 \
                        -Dsonar.token=$SONAR_TOKEN \
                        -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                    """
                }
            }
        }

        stage('Zip Build') {
            steps {
                sh '''
                    rm -f build.zip
                    cd dist
                    zip -r ../build.zip *
                '''
            }
        }

        stage('Upload to S3') {
            steps {
                withAWS(credentials: AWS_CREDENTIALS, region: REGION) {
                    sh "aws s3 cp build.zip s3://${S3_BUCKET}/react_app/build.zip"
                }
            }
        }

        stage('Trigger Lambda Deploy') {
            steps {
                withAWS(credentials: AWS_CREDENTIALS, region: REGION) {
                    sh """
                    aws lambda invoke \
                        --function-name lambda_function \
                        --region ${REGION} \
                        response.json
                    """
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'build.zip', fingerprint: true
            echo 'Pipeline finished!'
        }
    }
}
