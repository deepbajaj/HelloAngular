pipeline {
  agent none
  stages {
    stage('Fetch dependencies') {
      agent {
        docker 'circleci/node:9.3-stretch-browsers'
      }
      steps {
        sh 'npm'
        stash includes: 'node_modules/', name: 'node_modules'
      }
    }
    stage('Lint') {
      agent {
        docker 'circleci/node:9.3-stretch-browsers'
      }
      steps {
        unstash 'node_modules'
        sh 'npm run lint'
      }
    }
    stage('Compile') {
      agent {
        docker 'circleci/node:9.3-stretch-browsers'
      }
      steps {
        unstash 'node_modules'
        sh 'npn run build --production'
        stash includes: 'dist/', name: 'dist'
      }
    }
    stage('Build and Push Docker Image') {
      agent any
      environment {
        DOCKER_PUSH = credentials('docker_push')
      }
      steps {
        unstash 'dist'
        sh 'docker build -t $DOCKER_PUSH_URL/frontend .'
        sh 'docker login -u $DOCKER_PUSH_USR -p $DOCKER_PUSH_PSW $DOCKER_PUSH_URL'
        sh 'docker push $DOCKER_PUSH_URL/frontend'
      }
    }
  }
}