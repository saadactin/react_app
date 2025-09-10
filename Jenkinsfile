pipeline {
    agent any

    environment {
        SONAR_TOKEN = credentials('sonar-token')
        AMPLIFY_APP_ID = credentials('amplify-app-id')
        AWS_CREDENTIALS = 'aws-jenkins'  // AWS credentials ID in Jenkins
        S3_BUCKET = 'lambdafunctionartifacts3'
        REGION = 'ap-south-1'
        NODE_VERSION = '22.13.1'
        NODE_DIR = "${WORKSPACE}/node"
        PATH = "${WORKSPACE}/node/bin:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/saadactin/react_app.git',
                    credentialsId: 'github-credentials' // GitHub credentials
            }
        }

        stage('Install Node.js') {
            steps {
                sh '''
                #!/bin/bash
                if [ ! -d "$NODE_DIR" ]; then
                    curl -sSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz | tar -xz -C $WORKSPACE
                    mv $WORKSPACE/node-v${NODE_VERSION}-linux-x64 $NODE_DIR
                fi
                echo "Node version:"
                $NODE_DIR/bin/node -v
                $NODE_DIR/bin/npm -v
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '$NODE_DIR/bin/npm install'
            }
        }

        stage('Build React Vite') {
            steps {
                sh '$NODE_DIR/bin/npm run build'
            }
        }

        stage('Run SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                    $NODE_DIR/bin/npx sonar-scanner \
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
