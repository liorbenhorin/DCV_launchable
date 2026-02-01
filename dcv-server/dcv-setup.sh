#!/bin/bash
# Initial setup script run once by systemd

# Set ubuntu user password
echo "ubuntu:brev1234" | chpasswd

# Create DCV log directory
mkdir -p /var/log/dcv
chown -R dcv:dcv /var/log/dcv

# Setup runtime directory for ubuntu user
mkdir -p /run/user/1000
chown ubuntu:ubuntu /run/user/1000
chmod 700 /run/user/1000

# Install Isaac Sim if not already installed
if [ ! -d "/home/ubuntu/.isaac/isaac" ]; then
    echo "Installing Isaac Sim environment (first boot only)..."
    echo "This may take 5-10 minutes. Check progress: tail -f /var/log/isaac-install.log"
    /usr/local/bin/setup-isaac.sh > /var/log/isaac-install.log 2>&1
    echo "Isaac Sim installation complete"
    # Create completion marker
    touch /home/ubuntu/.isaac/.install-complete
    chown ubuntu:ubuntu /home/ubuntu/.isaac/.install-complete
else
    echo "Isaac Sim environment already installed, skipping..."
fi

# Wait for DCV server to be ready
echo "Waiting for DCV server to start..."
for i in {1..30}; do
    if pgrep -x dcvserver > /dev/null; then
        echo "DCV server is running"
        break
    fi
    sleep 1
done

# Create virtual DCV session for ubuntu user
echo "Creating DCV virtual session..."
dcv create-session --type=virtual --owner ubuntu --storage-root /home/ubuntu ubuntu-session

echo "DCV session creation complete"
