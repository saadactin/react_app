pipeline {
    agent any

    environment {
        SONARQUBE = credentials('sonar-token')
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/saadactin/react_app.git', branch: 'main', credentialsId: 'github-credentials'
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
                    sh '''
                        npx sonar-scanner \
                          -Dsonar.projectKey=ReactApp \
                          -Dsonar.sources=src \
                          -Dsonar.host.url=http://host.docker.internal:9000 \
                          -Dsonar.token=$SONARQUBE \
                          -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                    '''
                }
            }
        }

        stage('Zip Build') {
            steps {
                sh '''
                    if ! command -v zip &> /dev/null
                    then
                      echo "Installing zip..."
                      apt-get update && apt-get install -y zip
                    fi
                    rm -f build.zip
                    cd dist
                    zip -r ../build.zip *
                '''
            }
        }

        stage('Upload to S3') {
            steps {
                withAWS(region: 'ap-south-1', credentials: 'aws-credentials') {
                    sh 'aws s3 cp build.zip s3://my-react-app-builds/build.zip --acl public-read'
                }
            }
        }

        stage('Trigger Lambda Deploy') {
            steps {
                sh '''
                  aws lambda invoke \
                    --function-name my-react-app-deploy \
                    --payload '{"action":"deploy"}' \
                    response.json
                '''
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
