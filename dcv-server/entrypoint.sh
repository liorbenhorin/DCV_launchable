#!/bin/bash
set -e

echo "Starting DCV Server container..."

# Set ubuntu user password
echo "ubuntu:1234" | chpasswd
echo "Ubuntu user password set to: 1234"

# Create PAM service for DCV
if [ ! -f /etc/pam.d/dcv ]; then
    cat > /etc/pam.d/dcv <<EOF
auth    requisite       pam_nologin.so
auth    required        pam_env.so readenv=1
auth    required        pam_env.so readenv=1 envfile=/etc/default/locale
auth    sufficient      pam_unix.so
auth    required        pam_deny.so
account sufficient      pam_unix.so
password        sufficient      pam_unix.so
session required        pam_unix.so
session optional        pam_systemd.so
EOF
    echo "Created PAM service for DCV"
fi

# Start SSH service
echo "Starting SSH service..."
/usr/sbin/sshd
if [ $? -eq 0 ]; then
    echo "SSH service started successfully"
else
    echo "Failed to start SSH service"
fi

# Start dbus (required for GNOME)
echo "Starting dbus..."
mkdir -p /run/dbus
rm -f /var/run/dbus/pid
dbus-daemon --system --fork
sleep 2

# Configure display
export DISPLAY=:0
export XDG_SESSION_TYPE=x11
export XDG_RUNTIME_DIR=/run/user/1000
mkdir -p $XDG_RUNTIME_DIR
chown ubuntu:ubuntu $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

# Create DCV log directory
mkdir -p /var/log/dcv
chown ubuntu:ubuntu /var/log/dcv

# Start DCV server daemon
echo "Starting DCV server..."
dcvserver 2>&1 &
DCV_PID=$!
sleep 5

# Check if DCV server is running
if ps -p $DCV_PID > /dev/null; then
    echo "DCV server is running (PID: $DCV_PID)"
else
    echo "ERROR: DCV server failed to start!"
    cat /var/log/dcv/server.log 2>/dev/null || echo "No server log available"
    exit 1
fi

# Wait for DCV server to be ready
echo "Waiting for DCV server to be ready..."
for i in {1..30}; do
    if dcv list-sessions 2>/dev/null; then
        echo "DCV server is ready"
        break
    fi
    sleep 1
done

# Create DCV console session for ubuntu user
echo "Creating DCV console session..."
dcv create-session --type=console --owner ubuntu --storage-root /home/ubuntu console 2>&1 || {
    echo "Note: Console session creation returned error, checking if session exists..."
    dcv list-sessions
}

# List active sessions
echo "=============================================="
echo "Active DCV sessions:"
dcv list-sessions
echo "=============================================="
echo "DCV Server is ready!"
echo "=============================================="
echo "Access via:"
echo "  DCV: https://<host>:8443"
echo "  SSH: ssh ubuntu@<host>"
echo "Credentials:"
echo "  Username: ubuntu"
echo "  Password: 1234"
echo "=============================================="

# Keep container running and show logs
echo "Tailing DCV server logs..."
tail -f /var/log/dcv/server.log 2>/dev/null || {
    echo "Server log not available, keeping container alive..."
    tail -f /dev/null
}
