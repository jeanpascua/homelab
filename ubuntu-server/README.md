# ubuntu-server

Scripts and configs for the Ubuntu Server VM (192.168.1.79).

## Scripts

### backup-docker.sh

Daily backup of all Docker volumes to Proxmox at 3am. Keeps 7 days of history. Volumes: Nextcloud data, Pi-hole config, NPM config and certs.

Install via root crontab:
```
0 3 * * * /usr/local/bin/backup-docker.sh
```

### dns-boot-check.sh + dns-boot-check.service

Fixes common DNS breakage on boot:

- Ensures `/etc/resolv.conf` points to the systemd-resolved stub
- Starts systemd-resolved if not running
- Sets Tailscale `accept-dns=true` (required for MagicDNS + split DNS)
- Logs to `/var/log/dns-boot-check.log`

Install:
```bash
sudo cp dns-boot-check.sh /usr/local/bin/
sudo cp dns-boot-check.service /etc/systemd/system/
sudo systemctl enable --now dns-boot-check.service
```

### sync-secrets.sh / sync-secrets-root.sh

Syncs secrets from Bitwarden to local `.env` files used by Docker services and systemd units. `sync-secrets-root.sh` handles root-owned destinations.

## Config Dirs

| Dir | What it configures |
|-----|-------------------|
| `fail2ban/` | fail2ban jail config for SSH brute-force protection |
| `ufw/` | UFW firewall rules |
| `journald.conf.d/` | journald log retention settings |
| `pam/` | PAM login notification config |
