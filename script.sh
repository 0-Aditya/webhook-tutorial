#!/bin/bash
set -e

IMAGE_NAME=nginx-welcome
CONTAINER_NAME=nginx-welcome-container
PORT=8090

echo "Stopping old container (if any)..."
docker rm -f $CONTAINER_NAME || true

echo "Building Docker image..."
docker build -t $IMAGE_NAME .

echo "Running container..."
docker run -d -p $PORT:80 --name $CONTAINER_NAME $IMAGE_NAME

echo "NGINX is live on port $PORT"

