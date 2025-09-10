pipeline {
    agent any

    environment {
        SONAR_TOKEN = credentials('sonar-token')
        AMPLIFY_APP_ID = credentials('amplify-app-id')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/saadactin/react_app.git'
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
                        -Dsonar.login=$SONAR_TOKEN \
                        -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                    """
                }
            }
        }

        stage('Zip Build') {
            steps {
                sh 'zip -r build.zip build/'
            }
        }

        stage('Upload to S3 (Trigger Lambda)') {
            steps {
                withAWS(credentials: 'aws-jenkins', region: 'ap-south-1') {
                    sh 'aws s3 cp build.zip s3://lambdafunctionartifacts3/react_app/build.zip'
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished!'
        }
    }
}
