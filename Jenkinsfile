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
    image: maven:3.8.6-jdk-11-slim
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
  - name: awscli
    image: amazon/aws-cli
    command:
      - 'sleep'
      - '999999'

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
    AWS_ROLE_ARN = "arn:aws:iam::189768267137:role/JenkinsPushToECR"
    AWS_WEB_IDENTITY_TOKEN_FILE = credentials('arch-aws-oidc')
    AWS_SDK_LOAD_CONFIG=true
  }

  stages {
    stage('Build') {
      steps {
        container('maven') {
          sh 'mvn --no-transfer-progress clean package'
        }
      }
    }
    stage('Build Docker image with Kaniko') {
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          withEnv(['PATH+EXTRA=/busybox']) {
            sh '''#!/busybox/sh
            echo '{"credsStore":"ecr-login"}' > /kaniko/.docker/config.json
            pwd
            /kaniko/executor --context "`pwd`" --destination 189768267137.dkr.ecr.us-east-1.amazonaws.com/dbuckman-pipelinetest:${GIT_COMMIT} --destination 189768267137.dkr.ecr.us-east-1.amazonaws.com/dbuckman-pipelinetest:latest
            '''
           }
        }
      }
    }
    stage('Deplopy to K8s') {
      steps {
        container('awscli') {
          sh 'aws sts get-caller-identity'
        }
        container('helm') {
          sh ' echo "helm xxxxxxx" '
        }
      }
    }
  }
}
