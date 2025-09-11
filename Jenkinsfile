pipeline {
    agent any

    tools {
        nodejs 'NodeJS'  // must exactly match Jenkins NodeJS installation
    }

    environment {
        SONAR_TOKEN = credentials('sonar-token')
        AMPLIFY_APP_ID = credentials('amplify-app-id')
        AWS_CREDENTIALS = 'aws-jenkins'
        S3_BUCKET = 'lambdafunctionartifacts3'
        REGION = 'ap-south-1'
    }

    stages {
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
                        -Dsonar.login=$SONAR_TOKEN \
                        -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                    """
                }
            }
        }

        stage('Zip Build') {
            steps {
                // Run PowerShell script for legacy zip
                powershell '''
                $source = "$(System.DefaultWorkingDirectory)\\dist"
                $zipFile = "$(System.DefaultWorkingDirectory)\\build.zip"
                
                if (Test-Path $zipFile) {
                    Remove-Item $zipFile
                }

                $fs = [System.IO.File]::Create($zipFile)
                $fs.Write([byte[]](80,75,5,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),0,22)
                $fs.Close()

                $shell = New-Object -ComObject shell.application
                $zip = $shell.NameSpace($zipFile)
                $sourceFolder = $shell.NameSpace($source)

                if ($zip -eq $null -or $sourceFolder -eq $null) {
                    Write-Error "Failed to open zip or source folder. Check your paths."
                    exit 1
                }

                $zip.CopyHere($sourceFolder.Items())
                Start-Sleep -Seconds 5

                Write-Output "Legacy zip created: $zipFile"
                '''
            }
        }

        stage('Upload to S3') {
            steps {
                withAWS(credentials: AWS_CREDENTIALS, region: REGION) {
                    powershell "aws s3 cp build.zip s3://${S3_BUCKET}/react_app/build.zip"
                }
            }
        }

        stage('Trigger Lambda Deploy') {
            steps {
                withAWS(credentials: AWS_CREDENTIALS, region: REGION) {
                    powershell """
                    aws lambda invoke `
                        --function-name lambda_function `
                        --region ${REGION} `
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
