#!/bin/bash

# Simple Docker management script for Chase Up Laravel app

CONTAINER_NAME="chase-up-container"
IMAGE_NAME="chase-up-app"
PORT="8000"

case "$1" in
    "start")
        echo "Starting Chase Up application..."
        docker run -d --name $CONTAINER_NAME -p $PORT:80 $IMAGE_NAME
        echo "Application started at http://localhost:$PORT"
        ;;
    "stop")
        echo "Stopping Chase Up application..."
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME
        echo "Application stopped"
        ;;
    "restart")
        echo "Restarting Chase Up application..."
        docker stop $CONTAINER_NAME 2>/dev/null
        docker rm $CONTAINER_NAME 2>/dev/null
        docker run -d --name $CONTAINER_NAME -p $PORT:80 $IMAGE_NAME
        echo "Application restarted at http://localhost:$PORT"
        ;;
    "logs")
        echo "Showing application logs..."
        docker logs -f $CONTAINER_NAME
        ;;
    "status")
        echo "Container status:"
        docker ps -a --filter name=$CONTAINER_NAME
        ;;
    "shell")
        echo "Opening shell in container..."
        docker exec -it $CONTAINER_NAME sh
        ;;
    "build")
        echo "Building Docker image..."
        docker build -t $IMAGE_NAME .
        echo "Image built successfully"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|logs|status|shell|build}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the application"
        echo "  stop    - Stop the application"
        echo "  restart - Restart the application"
        echo "  logs    - Show application logs"
        echo "  status  - Show container status"
        echo "  shell   - Open shell in container"
        echo "  build   - Build Docker image"
        exit 1
        ;;
esac
