# Isaac Sim DCV Brev Launchable

A Brev launchable that provides a complete Ubuntu 22.04 XFCE desktop environment with NICE DCV remote desktop access, GPU acceleration, and Isaac Sim support.

## Quick Connect

After deployment is complete, connect to your remote desktop:

**DCV Web Client (Recommended):**
- URL: `https://<instance-hostname>:8443/dcv`
- Username: `ubuntu`
- Password: `brev1234`

**DCV Native Client:**
- Download from: https://download.nice-dcv.com/
- Server: `<instance-hostname>:8443`
- Username: `ubuntu`
- Password: `brev1234`

**SSH Access:**
```bash
ssh ubuntu@<instance-hostname>
# Password: brev1234
```

## Overview

This launchable provides:
- **Remote Desktop**: NICE DCV server with web and native client support
- **SSH Access**: Standard SSH access for terminal operations
- **XFCE Desktop**: Modern Arc-Dark themed XFCE4 desktop with openbox window manager
- **GPU Acceleration**: NVIDIA GPU support for graphics and compute
- **Isaac Sim Environment**: Python 3.11 with Isaac Sim 5.1.0 and PyTorch pre-installed
- **Pre-installed Software**: Firefox, VSCode, and essential development tools

## Architecture

```
User Browser/Client → DCV Server (HTTPS :8443) → XFCE Desktop + GPU
User SSH Client → DCV Server (SSH :22)
```

## Prerequisites

- Brev account with access to GPU instances
- NVIDIA GPU-enabled instance
- Docker and Docker Compose installed
- Port 8443 and 22 available

## Quick Start

### 1. Clone and Deploy

```bash
git clone git@github.com:liorbenhorin/Isaac_DCV_launchable.git
cd Isaac_DCV_launchable
docker compose up -d
```

### 2. Check Status

```bash
docker compose ps
docker compose logs -f dcv-server
```

### 3. Connect

See **Quick Connect** section at the top of this README.

## Configuration

### Default Credentials

- **Username**: `ubuntu`
- **Password**: `brev1234`
- **Sudo**: Passwordless sudo enabled

### Ports

- **22**: SSH access
- **8443**: DCV server HTTPS access

### DCV Settings

The DCV server is configured with:
- Virtual session for `ubuntu` user (not console session)
- System authentication (PAM)
- 25 FPS target frame rate
- QUIC protocol enabled
- Clipboard integration
- Stylus and touch input support
- XFCE4 desktop with Arc-Dark theme and openbox window manager

Configuration file: `dcv-server/dcv.conf`

### Desktop Theme

- **GTK Theme**: Arc-Dark
- **Icon Theme**: Papirus-Dark
- **Window Manager**: openbox with Arc-Dark theme
- **Font**: Noto Sans
- **Alt+Click**: Disabled for window dragging (use Super+Click instead)

## Isaac Sim Environment

Pre-installed in the `isaac` virtual environment:
- **Python**: 3.11.14
- **Isaac Sim**: 5.1.0 with all extras
- **PyTorch**: 2.7.0 with CUDA 12.8
- **uv**: Fast Python package manager

The isaac environment is automatically activated in new terminal sessions.

To manually activate:
```bash
source /opt/isaac/isaac/bin/activate
```

## GPU Support

The container has access to all NVIDIA GPUs with full capabilities:
- GPU compute
- Graphics acceleration
- Display output
- CUDA support

Verify GPU access:
```bash
docker compose exec dcv-server nvidia-smi
```

## Volumes

- `dcv-home`: Persistent home directory for ubuntu user
- `dcv-cache`: System cache directory

## Troubleshooting

### DCV Server Not Starting

Check logs:
```bash
docker compose logs dcv-server
```

Verify DCV server is running:
```bash
docker compose exec dcv-server pgrep dcvserver
```

List DCV sessions:
```bash
docker compose exec dcv-server dcv list-sessions
```

### Cannot Connect to DCV

1. Verify DCV is listening on port 8443:
```bash
netstat -tlnp | grep 8443
```

2. Check DCV server status:
```bash
docker compose exec dcv-server systemctl status dcvserver
```

3. Recreate the session:
```bash
docker compose exec dcv-server dcv close-session ubuntu-session
docker compose exec dcv-server dcv create-session --type=virtual --owner ubuntu --storage-root /home/ubuntu ubuntu-session
```

### SSH Connection Issues

1. Verify SSH service is running:
```bash
docker compose exec dcv-server pgrep sshd
```

2. Test SSH locally:
```bash
ssh -p 22 ubuntu@localhost
```

### Display Issues

1. Check DCV session status:
```bash
docker compose exec dcv-server dcv list-sessions
```

2. Verify desktop components are running:
```bash
docker compose exec dcv-server ps aux | grep -E 'openbox|xfce4'
```

3. Check DCV logs:
```bash
docker compose exec dcv-server cat /var/log/dcv/server.log | tail -50
```

### GPU Not Detected

1. Verify NVIDIA runtime:
```bash
docker info | grep -i nvidia
```

2. Check GPU access in container:
```bash
docker compose exec dcv-server nvidia-smi
```

3. Verify video group membership:
```bash
docker compose exec dcv-server groups ubuntu
```

### Isaac Sim Issues

1. Verify environment is activated:
```bash
docker compose exec dcv-server bash -c 'source /opt/isaac/isaac/bin/activate && python --version'
```

2. Test Isaac Sim installation:
```bash
docker compose exec dcv-server bash -c 'source /opt/isaac/isaac/bin/activate && python -c "import isaacsim; print(isaacsim.__version__)"'
```

## Customization

### Change Password

Edit `dcv-server/dcv-setup.sh` and change the line:
```bash
echo "ubuntu:brev1234" | chpasswd
```

### Install Additional Software

Add packages to `dcv-server/Dockerfile`:
```dockerfile
RUN apt-get update && apt-get install -y \
    your-package-here \
    && apt-get clean
```

### Modify DCV Settings

Edit `dcv-server/dcv.conf` to customize:
- Frame rate: `target-fps`
- Authentication: `authentication`
- Clipboard: `primary-selection-paste`
- And more...

### Customize Isaac Environment

Edit `dcv-server/scripts/setup-isaac.sh` to add additional Python packages:
```bash
uv pip install your-package-here
```

## Brev Integration

### Brev Setup Script

The `brev-startup.sh` script is included for automatic deployment on Brev instances.

To use it on a Brev instance:

```bash
cd /path/to/Isaac_DCV_launchable
./brev-startup.sh
```

The setup script will:
- Verify Docker is available
- Deploy the stack using `docker compose`
- Display connection information

For Brev launchable configuration, use this setup script in your launchable's setup phase.

## Security Considerations

⚠️ **Important Security Notes:**

1. **Default Password**: The default password `brev1234` is for development use. Change it for production.
2. **Self-Signed Certificate**: DCV uses a self-signed SSL certificate. Your browser will show a warning.
3. **Privileged Container**: The DCV container runs in privileged mode for display manager access.
4. **Host Network**: Container uses host networking for simplicity. Consider bridge networking for isolation.

## Development

### Build Images

```bash
docker compose build
```

### Rebuild and Restart

```bash
docker compose down
docker compose up -d --build
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f dcv-server
```

### Shell Access

```bash
docker compose exec dcv-server bash
```

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

[Your License Here]

## Support

For issues and questions:
- GitHub Issues: https://github.com/liorbenhorin/Isaac_DCV_launchable/issues
- Documentation: https://github.com/liorbenhorin/Isaac_DCV_launchable

## Acknowledgments

- NICE DCV by AWS
- Ubuntu and XFCE projects
- NVIDIA Isaac Sim
- Brev.dev platform
