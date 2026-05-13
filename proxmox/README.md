# Proxmox Alerting Scripts

Discord alerts for homelab events. Both scripts read the webhook URL from
`/etc/homelab-alerts.env` so the secret stays off the repo.

## Files

- `homelab-watchdog.sh` — pings ubuntu VM (192.168.1.79) and checks proxmox
  root disk %. Edge-triggered Discord alerts on VM up/down and disk threshold
  (default 85%) crossings. State files in `/var/tmp/`.
- `vzdump-hook.sh` — proxmox backup phase hook. Discord alert on `backup-end`
  (size reported), `backup-abort`, and `job-abort`.

## Setup

1. Create the env file (root only):
   ```bash
   sudo install -m 600 -o root -g root /dev/null /etc/homelab-alerts.env
   echo 'DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...' | sudo tee /etc/homelab-alerts.env
   ```
2. Install scripts:
   ```bash
   sudo install -m 755 homelab-watchdog.sh /usr/local/bin/
   sudo install -m 755 vzdump-hook.sh /usr/local/bin/
   ```
3. Schedule the watchdog (root crontab):
   ```
   * * * * * /usr/local/bin/homelab-watchdog.sh
   ```
4. Register the backup hook in `/etc/vzdump.conf`:
   ```
   script: /usr/local/bin/vzdump-hook.sh
   ```

## Notes

- Scripts no-op silently if `/etc/homelab-alerts.env` is missing or
  `DISCORD_WEBHOOK_URL` is empty — safe to deploy before the env file exists.
- State files: `/var/tmp/homelab_watchdog_state`,
  `/var/tmp/homelab_watchdog_disk_state`. Delete to force re-alert.
