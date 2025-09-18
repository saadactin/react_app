pipeline {
    agent any   // run on any available Jenkins agent
    
    environment {
        REGISTRY_URL = "nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085"
        REGISTRY_REPO = "saadrepo"
        IMAGE_NAME = "face-detection"
        IMAGE_TAG = "v1"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t $IMAGE_NAME:latest .
                    docker image ls
                '''
            }
        }

        stage('Login to Nexus Registry') {
            steps {
                sh '''
                    docker login $REGISTRY_URL -u admin -p Changeme@2025
                '''
            }
        }

        stage('Tag & Push Image') {
            steps {
                sh '''
                    docker tag $IMAGE_NAME:latest $REGISTRY_URL/$REGISTRY_REPO/$IMAGE_NAME:$IMAGE_TAG
                    docker push $REGISTRY_URL/$REGISTRY_REPO/$IMAGE_NAME:$IMAGE_TAG
                    docker image ls
                '''
            }
        }
    }
}
