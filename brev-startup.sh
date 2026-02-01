#!/bin/bash
# Brev Launchable Startup Script for DCV
# This script automatically deploys the DCV stack on instance startup

set -e

cd ~/DCV_launchable

echo "Starting DCV Launchable deployment..."

# Deploy using docker compose
docker compose up -d --build

# Wait for DCV to be ready
echo "Waiting for DCV desktop to initialize..."
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
echo "  Password: brev1234"
echo ""
echo "=========================================="
echo ""
echo "Installing Isaac Sim (this may take 5-10 minutes)..."
echo "=========================================="
echo ""

# Wait for installation to start
sleep 5

# Follow installation logs until complete
while ! docker compose exec -T dcv-server test -f /home/ubuntu/.isaac/.install-complete 2>/dev/null; do
    # Show the last few lines of the log if it exists
    if docker compose exec -T dcv-server test -f /var/log/isaac-install.log 2>/dev/null; then
        docker compose exec -T dcv-server tail -n 3 /var/log/isaac-install.log 2>/dev/null || true
    fi
    sleep 10
done

echo ""
echo "=========================================="
echo "Isaac Sim installation complete!"
echo "=========================================="
echo ""
echo "You can now run 'isaacsim' from a terminal in the desktop."
echo ""
