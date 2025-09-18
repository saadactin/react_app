pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: dind
    image: docker:dind
    command:
    - cat
    tty: true
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
    volumeMounts:
    - name: regcred
      mountPath: /kaniko/.docker   # Nexus credentials secret
  volumes:
  - name: regcred
    secret:
      secretName: regcred
'''
        }
    }

    environment {
        REGISTRY = "nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085"
        IMAGE = "saad:latest"   // <-- your image name
    }

    stages {
        stage('Build Docker Image') {
            steps {
                container('dind') {
                    sh '''
                        docker build -t $IMAGE .
                        docker image ls
                    '''
                }
            }
        }

        stage('Push to Nexus') {
            steps {
                container('dind') {
                    sh '''
                        # Push using secret-mounted credentials
                        docker push $REGISTRY/$IMAGE
                        docker pull $REGISTRY/$IMAGE
                        docker image ls
                    '''
                }
            }
        }
    }
}
