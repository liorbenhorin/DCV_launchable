# Isaac Sim DCV Brev Launchable

An unofficial sample Brev launchable providing Ubuntu 22.04 desktop environment with DCV remote access, GPU acceleration, and Isaac Sim 5.1.0.

## Features

- DCV server with web-based remote desktop access
- Isaac Sim 5.1.0
- Ubuntu Desktop with Firefox and VSCode
- NVIDIA GPU

## Quick Start

### Deploy on Brev

1. [Deploy here](https://brev.nvidia.com/launchable/deploy?launchableID=env-38thl4fP60kYlwOPvpYBZtdvyYs)

   Note: Deployment can take up to 20 minutes.

2. Connect to remote desktop:
   - **URL**: `https://<instance-hostname>:8443/dcv`
   - **Username**: `ubuntu`
   - **Password**: `brev1234`

3. From the desktop, open a terminal window and run:
   ```bash
   isaacsim
   ```

### Connect via Brev Shell

```bash
brev shell <your-instance-name>
```

Common commands:
- Check status: `docker compose ps`
- View logs: `docker compose logs -f dcv-server`
- Restart services: `docker compose restart`

## Troubleshooting

### Session Dropped or Not Available

1. Check if DCV is running:
```bash
docker compose exec dcv-server pgrep dcvserver
```

2. List active sessions:
```bash
docker compose exec dcv-server dcv list-sessions
```

3. Recreate the session:
```bash
docker compose exec dcv-server dcv close-session ubuntu-session
docker compose exec dcv-server dcv create-session --type=virtual --owner ubuntu --storage-root /home/ubuntu ubuntu-session
```

4. Restart the stack:
```bash
docker compose restart
```

## Isaac Sim Environment

The `isaac` virtual environment is automatically activated in new terminals.

To manually activate:
```bash
source ~/.isaac/isaac/bin/activate
```