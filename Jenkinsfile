pipeline {
    agent any

    tools {
        nodejs 'NodeJS' // Must match the NodeJS installation name in Jenkins Global Tool Configuration (use Node 22.13.1)
    }

    environment {
        SONAR_TOKEN = credentials('sonar-token')
        AMPLIFY_APP_ID = credentials('amplify-app-id')
        AWS_CREDENTIALS = 'aws-jenkins'  // AWS credentials ID in Jenkins
        S3_BUCKET = 'lambdafunctionartifacts3'
        REGION = 'ap-south-1'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/saadactin/react_app.git',
                    credentialsId: 'github-credentials' // GitHub credentials configured in Jenkins
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build React Vite') {
            steps {
                sh 'npm run build'  // Vite outputs to 'dist' folder by default
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
                        -Dsonar.login=$SONAR_TOKEN \
                        -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                    """
                }
            }
        }

        stage('Zip Build') {
            steps {
                sh '''
                cd dist
                zip -r ../build.zip .
                '''
            }
        }

        stage('Upload to S3 (Trigger Lambda)') {
            steps {
                withAWS(credentials: AWS_CREDENTIALS, region: REGION) {
                    sh "aws s3 cp build.zip s3://${S3_BUCKET}/react_app/build.zip"
                }
            }
        }

        stage('Trigger Lambda Deploy') {
            steps {
                withAWS(credentials: AWS_CREDENTIALS, region: REGION) {
                    sh "aws lambda invoke --function-name frontend_react --region ${REGION} response.json"
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
