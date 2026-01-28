#!/bin/bash
# Brev Launchable Startup Script for DCV
# This script automatically deploys the DCV stack on instance startup

set -e

cd ~/DCV_launchable

echo "Starting DCV Launchable deployment..."

# Pull latest changes if git repo exists
if [ -d .git ]; then
    git pull || true
fi

# Deploy using docker compose
docker compose up -d --build

# Wait for services to be ready
echo "Waiting for services to initialize..."
sleep 35

# Display connection info
PUBLIC_IP=$(curl -s ifconfig.me)

echo ""
echo "=========================================="
echo "DCV Desktop is ready!"
echo "=========================================="
echo ""
echo "Connect to your desktop:"
echo "  https://${PUBLIC_IP}:8443/dcv"
echo ""
echo "Credentials:"
echo "  Username: ubuntu"
echo "  Password: brevdemo123"
echo ""
echo "=========================================="
