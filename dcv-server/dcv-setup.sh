#!/bin/bash
# Initial setup script run once by systemd

# Set ubuntu user password
echo "ubuntu:brevdemo123" | chpasswd

# Create DCV log directory
mkdir -p /var/log/dcv
chown -R dcv:dcv /var/log/dcv

# Setup runtime directory for ubuntu user
mkdir -p /run/user/1000
chown ubuntu:ubuntu /run/user/1000
chmod 700 /run/user/1000

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
