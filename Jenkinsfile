pipeline {
  agent {
    kubernetes {
      label 'mypod'
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: some-label-value
spec:
  containers:
  - name: maven
    image: maven:3.6.1-jdk-8-slim
    command:
    - cat
    tty: true
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
  - name: helm
    image: lachlanevenson/k8s-helm:v2.12.3
    command:
    - cat
    tty: true

  volumes:
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: dbuckman-docker-credentials
          items:
            - key: .dockerconfigjson
              path: config.json
"""
    }
  }

  environment {
    //Use Pipeline Utility Steps plugin to read information from pom.xml into env variables
    IMAGE = readMavenPom().getArtifactId()
    VERSION = readMavenPom().getVersion().replace("-SNAPSHOT", "")
  }

  stages {
    stage('Build') {
      steps {
        container('maven') {
          sh 'mvn clean package'
        }
      }
    }
    stage('Build Docker image with Kaniko') {
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          withEnv(['PATH+EXTRA=/busybox']) {
            sh '''#!/busybox/sh
            pwd
            /kaniko/executor --context "`pwd`" --destination dbuckmancb/${IMAGE}:${VERSION}
            '''
           }
        }
      }
    }
    stage('Deplopy to K8s') {
      steps {
        container('helm') {
          sh ' echo "helm xxxxxxx" '
        }
      }
    }
  }
}
