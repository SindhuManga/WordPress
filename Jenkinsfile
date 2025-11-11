pipeline {
  agent any
  environment {
    DOCKERHUB_CRED = credentials('dockerhub-creds')   // id in Jenkins credentials
    AWS_ACCESS_KEY = credentials('aws-access-key')    // id in Jenkins credentials (username=access, password=secret)
    AWS_SECRET_KEY = credentials('aws-secret-key')    // OR use Jenkins' AWS plugin
    SSH_KEY = credentials('ec2-ssh-key')              // SSH private key credential
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build & Push Image') {
      when { expression { fileExists('docker/Dockerfile') } } // only if you have a Dockerfile
      steps {
        sh 'docker --version'
        sh "echo ${DOCKERHUB_CRED_PSW} | docker login -u ${DOCKERHUB_CRED_USR} --password-stdin"
        sh 'docker build -t yourdockerhubusername/wordpress:latest docker/'
        sh 'docker push yourdockerhubusername/wordpress:latest'
      }
    }

    stage('Terraform Apply') {
      steps {
        dir('infra') {
          withEnv(["AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_USR}", "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_KEY_PSW}"]) {
            sh 'terraform init -input=false'
            sh 'terraform apply -auto-approve -input=false'
            sh 'terraform output -json > tf_output.json'
          }
        }
      }
    }

    stage('Deploy to EC2') {
      steps {
        script {
          def out = readFile 'infra/tf_output.json'
          def ip = sh(script: "jq -r .public_ip.value infra/tf_output.json", returnStdout: true).trim()
          // write SSH key to file
          writeFile file: 'ec2_key.pem', text: env.SSH_KEY_PSW
          sh "chmod 600 ec2_key.pem"
          // copy docker-compose to server (or pull from git there)
          sh "scp -o StrictHostKeyChecking=no -i ec2_key.pem compose/docker-compose.yml ubuntu@${ip}:/home/ubuntu/docker-compose.yml"
          // remote run: pull new image and up
          sh "ssh -o StrictHostKeyChecking=no -i ec2_key.pem ubuntu@${ip} 'sudo mv /home/ubuntu/docker-compose.yml /opt/wordpress/compose/docker-compose.yml || true && cd /opt/wordpress/compose && docker-compose pull && docker-compose up -d --remove-orphans'"
        }
      }
    }
  }

  post {
    always {
      sh 'docker logout || true'
    }
  }
}
