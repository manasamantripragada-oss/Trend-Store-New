pipeline {
  agent any

  environment {
    DOCKER_REPO = "manasadevi09/trendify-app"
    IMAGE_TAG   = "${BUILD_NUMBER}"
    AWS_REGION  = "ap-south-1"
    EKS_CLUSTER = "trendify-cluster"
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main',
        url: 'https://github.com/manasamantripragada-oss/Trend-Store-New'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
        docker build -t $DOCKER_REPO:$IMAGE_TAG .
        docker tag $DOCKER_REPO:$IMAGE_TAG $DOCKER_REPO:latest
        '''
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub-creds',
          usernameVariable: 'USER',
          passwordVariable: 'PASS'
        )]) {
          sh '''
          echo $PASS | docker login -u $USER --password-stdin
          docker push $DOCKER_REPO:$IMAGE_TAG
          docker push $DOCKER_REPO:latest
          '''
        }
      }
    }

    stage('Configure EKS Access') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws-creds'
        ]]) {
          sh '''
          aws eks update-kubeconfig \
            --region $AWS_REGION \
            --name $EKS_CLUSTER
          kubectl get nodes
          '''
        }
      }
    }

    stage('Deploy to EKS') {
      steps {
        sh '''
        kubectl apply -f deployment.yml
        kubectl apply -f service.yml

        kubectl set image deployment/trendify-deployment \
          trendify-container=$DOCKER_REPO:$IMAGE_TAG
        kubectl rollout status deployment/trendify-deployment
        '''
      }
    }
  }
}
