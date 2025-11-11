pipeline {
  agent any

  environment {
    DOCKERHUB_CRED = credentials('dockerhub-creds')     // Docker Hub credentials ID in Jenkins
    AWS_CREDS = credentials('aws-access-key')           // AWS access + secret key
    SSH_KEY = credentials('ec2-ssh-key')                // EC2 private key (SSH)
  }

  stages {
    stage('Checkout') {
      steps {
        echo '📥 Checking out source code...'
        checkout scm
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        echo '🐳 Building and pushing WordPress image to Docker Hub...'
        sh 'docker --version'
        sh "echo ${DOCKERHUB_CRED_PSW} | docker login -u ${DOCKERHUB_CRED_USR} --password-stdin"
        sh 'docker build -t sindhu2303/wordpress:latest .'     // build from root
        sh 'docker push sindhu2303/wordpress:latest'
      }
    }

    stage('Terraform Apply') {
      steps {
        dir('Terraform') {      // match your folder name
          echo '🏗️  Initializing and applying Terraform...'
          withEnv(["AWS_ACCESS_KEY_ID=${AWS_CREDS_USR}", "AWS_SECRET_ACCESS_KEY=${AWS_CREDS_PSW}"]) {
            sh 'terraform init -input=false'
            sh 'terraform apply -auto-approve -input=false'
            sh 'terraform output -json > tf_output.json'
          }
        }
      }
    }

    stage('Deploy on EC2') {
      steps {
        script {
          echo '🚀 Deploying WordPress on EC2...'
          def ip = sh(script: "jq -r .public_ip.value Terraform/tf_output.json", returnStdout: true).trim()

          // save SSH key for EC2 connection
          writeFile file: 'ec2_key.pem', text: env.SSH_KEY_PSW
          sh "chmod 600 ec2_key.pem"

          // copy docker-compose to EC2
          sh "scp -o StrictHostKeyChecking=no -i ec2_key.pem docker-compose.yml ubuntu@${ip}:/home/ubuntu/docker-compose.yml"

          // start containers remotely
          sh "ssh -o StrictHostKeyChecking=no -i ec2_key.pem ubuntu@${ip} 'sudo mkdir -p /opt/wordpress && sudo mv /home/ubuntu/docker-compose.yml /opt/wordpress/docker-compose.yml && cd /opt/wordpress && sudo docker-compose pull && sudo docker-compose up -d --remove-orphans'"
        }
      }
    }
  }

  post {
    always {
      sh 'docker logout || true'
      echo '✅ Pipeline completed!'
    }
  }
}
