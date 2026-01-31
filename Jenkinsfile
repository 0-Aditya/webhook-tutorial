pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t nginx-welcome .'
            }
        }

        stage('Run NGINX Container') {
            steps {
                sh '''
                # Stop and remove old container if exists
                docker rm -f nginx-test || true

                # Run new container
                docker run -d -p 8080:80 --name nginx-test nginx-welcome
                '''
            }
        }
    }

    post {
        success {
            echo 'NGINX is running on http://<jenkins-node-ip>:8080'
        }
    }
}
