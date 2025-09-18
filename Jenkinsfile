pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: regcred
      mountPath: /kaniko/.docker
  volumes:
  - name: regcred
    secret:
      secretName: regcred   # Nexus Docker credentials
"""
        }
    }

    environment {
        REGISTRY = "nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085"
        IMAGE = "saad:latest"
    }

    stages {
        stage('Build & Push Docker Image') {
            steps {
                container('kaniko') {
                    sh '''
                        /kaniko/executor \
                          --context `pwd` \
                          --dockerfile Dockerfile \
                          --destination $REGISTRY/$IMAGE
                    '''
                }
            }
        }
    }
}
