#!/bin/bash

# Name of the Docker registry image, e.g., your Docker Hub username and repository name
IMAGE_NAME="mhoctavian/adapter:latest"
STACK_NAME="tema3"

# Function to stop everything immediately (reset functionality)
reset_stack() {
    echo "Stopping everything..."
    docker stack rm "$STACK_NAME"
    echo "Waiting for the stack to fully remove..."
    sleep 10
    echo "Pruning networks and volumes..."
    docker network prune -f
    docker volume prune -f
    echo "All services and networks stopped."

    echo "Initializing Docker Swarm..."
    docker swarm init

    echo "Building adapter image..."
    docker build -t "$IMAGE_NAME" ./adapter

    echo "Pushing image $IMAGE_NAME to Docker registry..."
    docker push "$IMAGE_NAME"

    echo "Deploying stack $STACK_NAME..."
    docker stack deploy -c stack.yml "$STACK_NAME"

    echo "Deployment completed! Checking services..."
    docker service ls
}

# Function to restart the stack without deleting persistent data
restart_stack() {
    echo "Restarting stack $STACK_NAME..."
    docker stack deploy -c stack.yml "$STACK_NAME"
    echo "Deployment completed! Checking services..."
    docker service ls
}

# Function to show usage
show_usage() {
    echo "Usage: $0 {reset|restart}"
    echo
    echo "reset   - Stops all services, deletes volumes and networks, rebuilds everything from scratch."
    echo "restart - Restarts services while preserving persistent data (volumes) and shows configuration."
    exit 1
}

# Main logic to handle reset and restart commands
if [[ "$#" -ne 1 ]]; then
    show_usage
fi

case "$1" in
    reset)
        reset_stack
        ;;
    restart)
        restart_stack
        ;;
    *)
        show_usage
        ;;
esac
