📘 Jenkins + Docker + NGINX Deployment Documentation
Overview

This document explains how a GitHub webhook–triggered Jenkins pipeline is used to build and run an NGINX container on an EC2 instance using Docker.

The setup demonstrates:

Automated CI trigger via GitHub webhook

Jenkins pipeline execution

Docker image build

Docker container deployment exposing the NGINX welcome page

Architecture Overview
GitHub Push
   ↓
Webhook
   ↓
Jenkins Pipeline
   ↓
Shell Script (script.sh)
   ↓
Docker Build & Run
   ↓
NGINX Welcome Page

Prerequisites

Jenkins installed on EC2

Docker installed on the same EC2 instance

Jenkins user added to Docker group

GitHub repository connected via webhook

Port 8080 & 8090 allowed in EC2 Security Group

Repository Structure
webhook-tutorial/
│── Dockerfile
│── Jenkinsfile
│── script.sh

Dockerfile

The Dockerfile uses the official NGINX image, which already contains the default welcome page.

FROM nginx:latest
EXPOSE 80

Jenkins Pipeline

The Jenkins pipeline is responsible only for:

Pulling the code from GitHub

Executing a deployment script from the repository

pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(
                    branches: [[name: '*/master']],
                    userRemoteConfigs: [[
                        credentialsId: 'github-creds',
                        url: 'https://github.com/0-Aditya/webhook-tutorial.git'
                    ]]
                )
            }
        }

        stage('Build & Run Container') {
            steps {
                sh '''
                chmod +x script.sh
                ./script.sh
                '''
            }
        }
    }
}

Deployment Script (script.sh)

This script contains all Docker-related logic.

#!/bin/bash
set -e

IMAGE_NAME=nginx-welcome
CONTAINER_NAME=nginx-welcome-container
PORT=8090   # 8080 is used by Jenkins

echo "Stopping old container (if any)..."
docker rm -f $CONTAINER_NAME || true

echo "Building Docker image..."
docker build -t $IMAGE_NAME .

echo "Running container..."
docker run -d -p $PORT:80 --name $CONTAINER_NAME $IMAGE_NAME

echo "NGINX is live on port $PORT"

Before Adding the Script
Behavior

Jenkins pipeline only checked out the repository

No Docker image was built

No container was running

No application was exposed on EC2

Webhook trigger worked, but no deployment occurred

Result

Pipeline completed successfully

No visible output or running service

Jenkins acted only as a code fetcher

After Adding the Script
Behavior

Webhook triggers Jenkins automatically on every push

Jenkins pulls the latest code

Jenkins executes script.sh

Docker image is built from the Dockerfile

Existing container (if any) is removed

New container is started on port 8090

Result

Fully automated deployment

NGINX welcome page is accessible at:

http://<EC2_PUBLIC_IP>:8090


Each Git push redeploys the container cleanly

Port Mapping Explanation

The container is started with:

docker run -d -p 8090:80 nginx-welcome


This means:

EC2 Port 8090  →  Container Port 80 (NGINX)


Port 8080 is avoided because Jenkins runs on it.

Common Issues & Resolutions
Port Already in Use

Cause: Jenkins uses port 8080

Fix: Use port 8090 or any free port

Permission Denied (Docker)
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

NGINX Not Accessible Externally

Ensure EC2 Security Group allows inbound TCP on port 8090

Conclusion

This setup converts Jenkins from a simple CI tool into a basic CI/CD system, capable of:

Responding to GitHub events

Building Docker images

Running containers automatically

It represents a foundational, real-world DevOps workflow suitable for learning and extension into production-grade systems.
