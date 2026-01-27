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

# Start GDM3 display manager
echo "Starting GDM3 display manager..."
systemctl start gdm3 2>/dev/null || /usr/sbin/gdm3 &
sleep 5

# Start DCV server
echo "Starting DCV server..."
dcvserver -d
sleep 3

# Check if DCV server is running
if pgrep -x "dcvserver" > /dev/null; then
    echo "DCV server is running"
else
    echo "Warning: DCV server may not have started correctly"
fi

# Create DCV console session for ubuntu user
echo "Creating DCV console session..."
dcv create-session --type=console --owner ubuntu console --storage-root /home/ubuntu
if [ $? -eq 0 ]; then
    echo "DCV console session created successfully"
else
    echo "Note: Console session may already exist or will be created automatically"
fi

# List active sessions
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

# Keep container running and tail logs
tail -f /var/log/dcv/server.log 2>/dev/null || tail -f /dev/null
