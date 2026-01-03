#!/bin/bash

# GPU Model Monitor Setup Script
# Provides convenient commands for managing the service

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

check_requirements() {
    echo "[+] Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo "[-] Docker is not installed"
        exit 1
    fi
    echo "[+] Docker: Found"
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo "[-] Docker Compose is not installed"
        exit 1
    fi
    echo "[+] Docker Compose: Found"
    
    # Check NVIDIA Docker Runtime
    if ! docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi &> /dev/null; then
        echo "[-] NVIDIA Docker Runtime not properly configured"
        echo "    Please install NVIDIA Container Toolkit"
        exit 1
    fi
    echo "[+] NVIDIA Docker Runtime: Found"
    
    # Check for GPU
    if ! nvidia-smi &> /dev/null; then
        echo "[-] nvidia-smi not found. Is NVIDIA driver installed?"
        exit 1
    fi
    echo "[+] NVIDIA GPU: Found"
}

start_service() {
    check_requirements
    echo "[+] Starting GPU Model Monitor..."
    
    if command -v docker-compose &> /dev/null; then
        docker-compose up -d
    else
        docker compose up -d
    fi
    
    echo "[+] GPU Model Monitor started successfully!"
    echo "[+] Dashboard available at: http://localhost:8081"
    echo "[+] To check logs: $0 logs"
}

stop_service() {
    echo "[+] Stopping GPU Model Monitor..."
    
    if command -v docker-compose &> /dev/null; then
        docker-compose down
    else
        docker compose down
    fi
    
    echo "[+] GPU Model Monitor stopped"
}

restart_service() {
    stop_service
    sleep 2
    start_service
}

status_service() {
    echo "[+] Checking GPU Model Monitor status..."
    docker ps --filter "name=gpu-model-monitor"
}

logs_service() {
    if command -v docker-compose &> /dev/null; then
        docker-compose logs -f
    else
        docker compose logs -f
    fi
}

build_service() {
    echo "[+] Building GPU Model Monitor..."
    
    if command -v docker-compose &> /dev/null; then
        docker-compose build
    else
        docker compose build
    fi
    
    echo "[+] Build complete!"
}

case "${1:-}" in
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart)
        restart_service
        ;;
    status)
        status_service
        ;;
    logs)
        logs_service
        ;;
    build)
        build_service
        ;;
    *)
        echo "GPU Model Monitor - Management Script"
        echo ""
        echo "Usage: $0 {start|stop|restart|status|logs|build}"
        echo ""
        echo "Commands:"
        echo "  start   - Start the GPU Model Monitor service"
        echo "  stop    - Stop the GPU Model Monitor service"
        echo "  restart - Restart the GPU Model Monitor service"
        echo "  status  - Check the status of the service"
        echo "  logs    - View service logs (live)"
        echo "  build   - Build the Docker image"
        exit 1
        ;;
esac
