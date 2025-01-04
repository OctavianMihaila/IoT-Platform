#!/bin/bash

IMAGE_NAME="mhoctavian/adapter:latest"
STACK_NAME="scd3"

# It says we should set this but is unused in my code.
export SCD_DVP=/var/lib/docker/volumes

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

show_usage() {
    echo "Usage: $0 {restart}"
    echo
    echo "If no argument is provided, the reset operation will run by default."
    echo "restart - Restarts services while preserving persistent data (volumes)."
    exit 1
}

# Main logic
if [[ "$#" -eq 0 ]]; then
    reset_stack
elif [[ "$1" == "restart" ]]; then
    restart_stack
else
    show_usage
fi
