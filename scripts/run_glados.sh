#!/bin/bash

# Function to stop containers and exit
cleanup() {
    echo "Stopping containers..."
    docker stop open-webui_with_ollama
    echo "Containers stopped. Exiting."
    exit 0
}

# Trap SIGINT (CTRL+C) and call cleanup function
trap cleanup SIGINT

# Start Ollama container
#echo "Starting Ollama container..."
#docker run -d --gpus=all --rm -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama

# Start Open WebUI container
echo "Starting Open WebUI container with ollama..."
#docker run -d --network=host -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://127.0.0.1:11434 --name open-webui --restart always ghcr.io/open-webui/open-webui:main
#docker run -d --rm -p 8080:8080 -v open-webui:/app/backend/data --name open-webui ghcr.io/open-webui/open-webui:latest
docker run -d -p 3000:8080 --gpus=all -v ollama:/root/.ollama -v open-webui:/app/backend/data --name open-webui_with_ollama --restart always ghcr.io/open-webui/open-webui:ollama

echo "Both containers are running. Press CTRL+C to stop."

# Keep the script running
while true; do
    sleep 1
done
