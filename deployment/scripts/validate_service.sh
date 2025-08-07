#!/bin/bash
# scripts/validate_service.sh
# Validate that the application is running and healthy

set -e

CONTAINER_NAME="viewport"
APP_PORT="5000"
MAX_RETRIES=30
RETRY_INTERVAL=5

echo "Validating application health..."

# Check if container is running
if [ ! $(docker ps -q -f name=$CONTAINER_NAME) ]; then
    echo "ERROR: Container $CONTAINER_NAME is not running"
    exit 1
fi

# Get container logs for debugging
echo "Container logs:"
docker logs --tail 20 $CONTAINER_NAME

# Health check function
health_check() {
    local url="http://localhost:$APP_PORT/health"
    
    # Try to reach health endpoint
    if curl -f -s $url > /dev/null 2>&1; then
        return 0
    else
        # Fallback to main endpoint if health endpoint doesn't exist
        if curl -f -s "http://localhost:$APP_PORT" > /dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    fi
}

# Perform health checks with retries
echo "Performing health checks..."
for i in $(seq 1 $MAX_RETRIES); do
    if health_check; then
        echo "✓ Health check passed (attempt $i/$MAX_RETRIES)"
        
        # Additional validation - check response content
        RESPONSE=$(curl -s http://localhost:$APP_PORT)
        if [[ $RESPONSE == *"Hello"* ]] || [[ $RESPONSE == *"Welcome"* ]]; then
            echo "✓ Application is responding correctly"
            echo "✓ Validation completed successfully"
            exit 0
        else
            echo "⚠ Application responded but content may be incorrect"
            echo "Response: $RESPONSE"
        fi
    else
        echo "✗ Health check failed (attempt $i/$MAX_RETRIES)"
        if [ $i -eq $MAX_RETRIES ]; then
            echo "ERROR: Health check failed after $MAX_RETRIES attempts"
            echo "Container status:"
            docker ps -f name=$CONTAINER_NAME
            echo "Container logs:"
            docker logs $CONTAINER_NAME
            exit 1
        fi
        sleep $RETRY_INTERVAL
    fi
done