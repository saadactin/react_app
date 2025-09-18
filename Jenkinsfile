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
    - name: kaniko-secret
      mountPath: /kaniko/.docker
  volumes:
  - name: kaniko-secret
    secret:
      secretName: regcred   # <-- this must be your Docker/Nexus registry secret
"""
        }
    }

    environment {
        REGISTRY = "nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085"
        IMAGE = "saad:latest"   // <-- renamed image here
    }

    stages {
        stage('Build & Push with Kaniko') {
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
