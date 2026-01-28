# DCV Launchable - Justfile for deployment commands

COMPOSE_LAUNCHER := "docker compose"

# Build Docker images
build:
    {{COMPOSE_LAUNCHER}} build

# Launch containers
launch:
    {{COMPOSE_LAUNCHER}} up -d

# Deploy (build and launch)
deploy: build launch
    @echo "=========================================="
    @echo "DCV Launchable Deployment Starting..."
    @echo "=========================================="
    @echo ""
    @echo "Waiting for services to start..."
    @sleep 15
    @echo ""
    @echo "Checking container status..."
    @{{COMPOSE_LAUNCHER}} ps
    @echo ""
    @echo "Waiting for DCV session to be created..."
    @sleep 20
    @echo ""
    @echo "=========================================="
    @echo "DCV Launchable Deployment Complete!"
    @echo "=========================================="
    @echo ""
    @echo "Access your DCV desktop:"
    @echo "  Web Client: https://$(curl -s ifconfig.me):8443/dcv"
    @echo "  SSH Access: ssh ubuntu@$(curl -s ifconfig.me)"
    @echo ""
    @echo "Credentials:"
    @echo "  Username: ubuntu"
    @echo "  Password: brevdemo123"
    @echo ""
    @echo "Useful commands:"
    @echo "  just status      - Check container status"
    @echo "  just dcv-status  - Check DCV session status"
    @echo "  just logs        - View all logs"
    @echo "  just dcv-logs    - View DCV server logs"
    @echo "=========================================="

# Show logs
logs:
    {{COMPOSE_LAUNCHER}} logs -f

# Show DCV-specific logs
dcv-logs:
    @echo "DCV Server Logs:"
    @{{COMPOSE_LAUNCHER}} exec dcv-server cat /var/log/dcv/server.log | tail -100

# Show DCV session status
dcv-status:
    @echo "DCV Sessions:"
    @{{COMPOSE_LAUNCHER}} exec dcv-server dcv list-sessions
    @echo ""
    @echo "Running Desktop Processes:"
    @{{COMPOSE_LAUNCHER}} exec dcv-server ps aux | grep -E 'openbox|xfce4-panel|xfdesktop' | grep -v grep || echo "No desktop processes found"

# Show status
status:
    {{COMPOSE_LAUNCHER}} ps

# Stop containers
stop:
    {{COMPOSE_LAUNCHER}} down

# Restart containers
restart: stop launch

# Restart DCV session only
restart-session:
    @echo "Restarting DCV session..."
    @{{COMPOSE_LAUNCHER}} exec dcv-server dcv close-session ubuntu-session || true
    @sleep 3
    @{{COMPOSE_LAUNCHER}} exec dcv-server dcv create-session --type=virtual --owner ubuntu --storage-root /home/ubuntu ubuntu-session
    @echo "DCV session restarted"

# Clean up (remove containers, images, volumes)
clean:
    {{COMPOSE_LAUNCHER}} down -v --rmi all
