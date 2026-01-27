# DCV Launchable Development Notes

## Project Overview
Building a Brev launchable for NICE DCV remote desktop that provides both SSH and DCV access to a desktop environment with GPU acceleration.

**Goal**: Create a production-ready DCV launchable similar to the isaac-sim launchable with automatic deployment via Justfile.

## Current Working State

### What's Working ✅
- **Desktop Environment**: XFCE4 with openbox window manager
- **DCV Server**: NICE DCV 2023.1 running on Ubuntu 22.04
- **Components Running**:
  - openbox (window manager) - lightweight, works in containers
  - xfce4-panel (top menu bar)
  - xfdesktop (desktop with icons)
  - xfce4-terminal (terminal application)
  - Firefox, VSCode installed
- **Access**: Both SSH (port 22) and DCV web (port 8443) working
- **Authentication**: ubuntu user with password "brevdemo123"
- **URL**: https://ec2-54-166-168-160.compute-1.amazonaws.com:8443/dcv

### Important Technical Notes
- **Window Manager Issue**: metacity, xfwm4, and nautilus all segfault in containers
- **Solution**: Using openbox window manager which is lightweight and stable
- **Session Type**: Virtual DCV sessions (not console sessions)
- **Init Script**: `/etc/dcv/dcvsessioninit` starts desktop components
- **Systemd**: Running systemd as PID 1 inside container (required for DCV)

## Working Environment

### Local Machine
- Location: `/home/lbenhorin/devel/brev/DCV_launchable`
- Running in WSL2 on local machine
- Git repo initialized and tracking changes

### Remote Instance (Brev)
- **Instance Name**: dcv-test-32d623
- **Instance Type**: g6e.16xlarge (GPU: NVIDIA L4)
- **Public IP**: ec2-54-166-168-160.compute-1.amazonaws.com
- **Region**: AWS EC2 us-east-1

### SSH Access to Remote Instance
```bash
# Using Brev SSH config (preferred)
ssh dcv-test-32d623

# Direct SSH (if needed)
ssh ubuntu@ec2-54-166-168-160.compute-1.amazonaws.com
# Password: brevdemo123
```

### Check Brev Instances
```bash
brev ls
```

## Development Workflow

### 1. Make Changes Locally
Edit files in `/home/lbenhorin/devel/brev/DCV_launchable/`

### 2. Sync to Remote Instance
```bash
rsync -avz /home/lbenhorin/devel/brev/DCV_launchable/ dcv-test-32d623:/home/ubuntu/DCV_launchable/
```

### 3. Rebuild and Restart on Remote
```bash
ssh dcv-test-32d623 "cd /home/ubuntu/DCV_launchable && docker compose down && docker compose build dcv-server && docker compose up -d"
```

### 4. Test
- **DCV Web UI**: https://ec2-54-166-168-160.compute-1.amazonaws.com:8443/dcv
- **SSH**: `ssh ubuntu@ec2-54-166-168-160.compute-1.amazonaws.com` (password: brevdemo123)
- **Username/Password**: ubuntu / brevdemo123

### 5. Check Status
```bash
# List running sessions
ssh dcv-test-32d623 "docker exec dcv-server dcv list-sessions"

# Check running processes
ssh dcv-test-32d623 "docker exec dcv-server ps aux | grep -E 'openbox|xfce4'"

# Check logs
ssh dcv-test-32d623 "docker exec dcv-server journalctl -u dcvserver -n 50"
```

### 6. Restart DCV Session (if needed)
```bash
ssh dcv-test-32d623 "docker exec dcv-server dcv close-session ubuntu-session && sleep 3 && docker exec dcv-server dcv create-session --type=virtual --owner ubuntu --storage-root /home/ubuntu ubuntu-session"
```

### 7. Commit to Git
```bash
git add -A
git commit -m "Your commit message

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Project Structure

```
DCV_launchable/
├── docker-compose.yml              # Main orchestration
├── docker-compose.override.yml     # Development builds
├── docker-compose.deployment.yml   # Production images (TODO)
├── README.md                        # User documentation
├── DEVELOPMENT_NOTES.md            # This file
├── Justfile                         # TODO: Deployment automation
├── .gitignore                       # Git ignore rules
├── dcv-server/                      # DCV server container
│   ├── Dockerfile                   # Ubuntu 22.04 + XFCE + DCV
│   ├── dcv.conf                     # DCV server config
│   ├── dcvsessioninit              # Session initialization script
│   ├── dcv-setup.sh                # Initial setup script
│   ├── dcv-setup.service           # Systemd service for setup
│   └── README.md                    # Server-specific docs
└── nginx/                           # SSL termination & proxy
    ├── Dockerfile                   # OpenResty nginx
    ├── entrypoint.sh                # SSL cert generation
    └── nginx.conf                   # Reverse proxy config
```

## Key Files

### dcv-server/Dockerfile
- Base: Ubuntu 22.04
- Desktop: XFCE4 + openbox window manager
- Packages: Firefox, VSCode, development tools
- DCV: NICE DCV 2023.1 from AWS
- User: ubuntu (UID 1000) with sudo access

### dcv-server/dcvsessioninit
- Started by DCV when creating sessions
- Launches: openbox, xfce4-panel, xfdesktop, xfce4-terminal
- Sets background, disables thumbnails for performance

### dcv-server/dcv.conf
- DCV server configuration
- Virtual session mode (not console)
- Authentication: system (PAM)
- Web port: 8443, URL path: /dcv

### dcv-server/dcv-setup.sh
- Runs once on container startup via systemd
- Sets ubuntu user password
- Creates DCV virtual session

## TODO List

### Priority 1: Improve Appearance
- [ ] Fix XFCE theme to look better with openbox
- [ ] Configure openbox theme/appearance
- [ ] Set proper wallpaper
- [ ] Configure desktop icons layout
- [ ] Add launcher/dock (like plank or xfce4-panel plugins)
- [ ] Test color schemes and fonts

**References**:
- Openbox themes: /usr/share/themes
- XFCE appearance settings: xfce4-appearance-settings
- Consider: Arc theme, Numix icons

### Priority 2: Complete Launchable (like isaac-sim)
- [ ] Create Justfile for automatic deployment
- [ ] Add deployment scripts
- [ ] Create pre-built Docker images
- [ ] Add docker-compose.deployment.yml with image references
- [ ] Add health checks and monitoring
- [ ] Document deployment process
- [ ] Add cleanup scripts

**Reference**: Look at isaac-launchable structure for patterns

### Priority 3: Performance Optimizations
- [ ] Investigate Thunar slow startup (20 seconds first launch)
- [ ] Test if Nautilus performs better (has daemon mode)
- [ ] Optimize DCV settings for lower latency
- [ ] Configure GPU acceleration properly
- [ ] Test frame rate settings

### Priority 4: Additional Features
- [ ] Add more applications (Chrome, IDEs, etc.)
- [ ] Configure clipboard sharing
- [ ] Add file transfer capabilities
- [ ] Multi-monitor support testing
- [ ] Audio support (if needed)

## Common Issues & Solutions

### Issue: Black screen with X cursor
**Cause**: Window manager not running
**Solution**: Use openbox instead of metacity/xfwm4

### Issue: No panel or desktop icons
**Cause**: XFCE components didn't start
**Solution**: Check dcvsessioninit script, restart session

### Issue: metacity/xfwm4/nautilus segfaults
**Cause**: Missing GNOME dependencies in container
**Solution**: Use openbox (lightweight, no GNOME deps)

### Issue: DCV session not created
**Cause**: License issues or server not ready
**Solution**: Check logs, ensure running on EC2 with proper metadata

### Issue: Slow file browser
**Cause**: Thumbnail generation
**Solution**: Set `TUMBLER_DISABLE=1` in session init

## Git Workflow

### Current Branch
`main`

### Commit Convention
Always include co-author tag:
```
git commit -m "Your message

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

### Important Commits
- `8dff14f` - Current working state: XFCE + openbox
- `c6aece0` - Added icon themes
- `4b09794` - Disabled thumbnail generation
- `94a717a` - Switched from GNOME to XFCE

## Testing Checklist

After any change, verify:
- [ ] Container builds successfully
- [ ] DCV server starts
- [ ] DCV session is created
- [ ] Can connect via DCV web UI
- [ ] Desktop appears with panel
- [ ] Terminal opens
- [ ] Icons are visible
- [ ] Window manager working (can move/resize windows)
- [ ] SSH access works

## Resources

### Documentation
- [NICE DCV Admin Guide](https://docs.aws.amazon.com/dcv/)
- [XFCE Documentation](https://docs.xfce.org/)
- [Openbox Documentation](http://openbox.org/wiki/Main_Page)

### Examples
- AWS Sample: https://github.com/aws-samples/aws-batch-using-nice-dcv
- Working example: https://repost.aws/questions/QUm2jjzH8YQSubxPBQeXwZqg/nice-dcv-docker-container-ubuntu

### Brev
- Brev instances: `brev ls`
- Brev documentation: https://docs.brev.dev/

## Quick Reference Commands

```bash
# Full rebuild and restart
rsync -avz /home/lbenhorin/devel/brev/DCV_launchable/ dcv-test-32d623:/home/ubuntu/DCV_launchable/ && \
ssh dcv-test-32d623 "cd /home/ubuntu/DCV_launchable && docker compose down && docker compose build dcv-server && docker compose up -d"

# Restart just the DCV session
ssh dcv-test-32d623 "docker exec dcv-server dcv close-session ubuntu-session && sleep 3 && docker exec dcv-server dcv create-session --type=virtual --owner ubuntu --storage-root /home/ubuntu ubuntu-session"

# Check what's running
ssh dcv-test-32d623 "docker exec dcv-server ps aux | grep -E 'openbox|xfce4-panel|xfdesktop'"

# View DCV logs
ssh dcv-test-32d623 "docker exec dcv-server cat /var/log/dcv/server.log | tail -50"

# Get shell in container
ssh dcv-test-32d623 "docker exec -it dcv-server bash"
```

## Notes for Future Context

If context is lost, remember:
1. **We are on local WSL**, SSH into remote Brev instance to test
2. **Use openbox**, not metacity/xfwm4 (they segfault)
3. **Commit often** to preserve working states
4. **User password** is "brevdemo123" (for testing)
5. **Desktop works but looks ugly** - that's the current TODO
6. **Goal**: Make it production-ready like isaac-sim launchable with Justfile
7. **Reference working example** from AWS re:Post for troubleshooting

---
*Last Updated: 2026-01-27 by Claude Sonnet 4.5*
