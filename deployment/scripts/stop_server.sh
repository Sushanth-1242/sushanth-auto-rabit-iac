#!/bin/bash
# scripts/stop_server.sh
# Stop the running application container

set -e

CONTAINER_NAME="viewport"

echo "Stopping application..."

# Check if container exists and is running
if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
    echo "Stopping container: $CONTAINER_NAME"
    docker stop $CONTAINER_NAME
    
    # Wait for graceful shutdown
    sleep 5
    
    # Force kill if still running
    if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
        echo "Force killing container..."
        docker kill $CONTAINER_NAME
    fi
    
    echo "Container stopped successfully"
else
    echo "Container $CONTAINER_NAME is not running"
fi

# Optional: Remove stopped container
if [ $(docker ps -aq -f name=$CONTAINER_NAME) ]; then
    echo "Removing stopped container..."
    docker rm $CONTAINER_NAME
fi

echo "Application stop completed"