#!/bin/bash

# Name of the Docker registry image, e.g., your Docker Hub username and repository name
IMAGE_NAME="mhoctavian/adapter:latest"
STACK_NAME="tema3"

# Function to stop everything immediately
stop_all() {
    echo "Stopping everything..."
    docker stack rm "$STACK_NAME"
    echo "Waiting for the stack to fully remove..."
    sleep 10
    echo "Pruning networks and volumes..."
    docker network prune -f
    docker volume prune -f
    echo "All services and networks stopped."
}

if docker info | grep -q "Swarm: active"; then
    stop_all
fi

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