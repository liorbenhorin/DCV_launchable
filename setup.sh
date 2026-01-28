#!/bin/bash
# Brev Setup Script for DCV Launchable
# This script runs when a new Brev instance is created

set -e

echo "============================================"
echo "DCV Launchable Setup Starting..."
echo "============================================"
echo ""

# Check if we're already in the repo directory
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: docker-compose.yml not found"
    echo "This script should be run from the DCV_launchable directory"
    exit 1
fi

# Ensure Docker is available
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Please install Docker first."
    exit 1
fi

# Start the services using just
if command -v just &> /dev/null; then
    echo "Using just to deploy..."
    just deploy
else
    echo "Just command not found, using docker compose directly..."
    docker compose up -d

    echo ""
    echo "Waiting for services to start..."
    sleep 35

    echo ""
    echo "============================================"
    echo "DCV Launchable Setup Complete!"
    echo "============================================"
    echo ""
    echo "Access your DCV desktop:"
    echo "  Web Client: https://$(curl -s ifconfig.me):8443/dcv"
    echo "  SSH Access: ssh ubuntu@$(curl -s ifconfig.me)"
    echo ""
    echo "Credentials:"
    echo "  Username: ubuntu"
    echo "  Password: brevdemo123"
    echo ""
    echo "Check status with: docker compose ps"
    echo "View logs with: docker compose logs -f"
    echo "============================================"
fi
