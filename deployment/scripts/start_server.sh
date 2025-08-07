#!/bin/bash
# scripts/start_server.sh
# Pull latest Docker image and start the application

set -e

# Configuration variables
AWS_REGION="us-east-1"
ECR_REGISTRY="461008418898.dkr.ecr.us-east-1.amazonaws.com"
IMAGE_NAME="flask/app"
IMAGE_TAG="latest"
CONTAINER_NAME="viewport"
APP_PORT="5000"

echo "Starting application deployment..."

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
echo "Instance ID: $INSTANCE_ID"

# Login to ECR
echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Stop and remove existing container if it exists
if [ $(docker ps -aq -f name=$CONTAINER_NAME) ]; then
    echo "Stopping existing container..."
    docker stop $CONTAINER_NAME || true
    docker rm $CONTAINER_NAME || true
fi

# Remove old images to save space
echo "Cleaning up old images..."
docker image prune -f

# Pull latest image
echo "Pulling latest image..."
docker pull $ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG

# Run new container
echo "Starting new container..."
docker run -d \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    -p $APP_PORT:$APP_PORT \
    --log-driver=awslogs \
    --log-opt awslogs-group="/aws/ec2/docker" \
    --log-opt awslogs-region=$AWS_REGION \
    --log-opt awslogs-stream="$INSTANCE_ID-$CONTAINER_NAME" \
    $ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG

# Wait for container to start
echo "Waiting for container to start..."
sleep 10

# Verify container is running
if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
    echo "Container started successfully"
    docker ps -f name=$CONTAINER_NAME
else
    echo "Failed to start container"
    docker logs $CONTAINER_NAME
    exit 1
fi

echo "Application deployment completed successfully"