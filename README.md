# Homelab

Personal homelab on a Lenovo M710q mini-PC ($110 CAD total). Running Proxmox VE as the hypervisor with an Ubuntu Server VM.

## Stack

```
Proxmox VE (bare metal)
└── Ubuntu Server VM (4 cores / 12GB RAM / 180GB disk)
    ├── Docker
    │   ├── Pi-hole               # Network-wide DNS ad blocking + .home resolution
    │   ├── Nextcloud             # Self-hosted personal cloud
    │   ├── OnlyOffice            # Document editing integrated with Nextcloud
    │   ├── Portainer             # Container management UI
    │   ├── Grafana               # Monitoring dashboards + Discord alerts
    │   ├── Prometheus            # Metrics collection
    │   ├── Node Exporter         # System metrics exporter
    │   ├── cAdvisor              # Container resource metrics
    │   ├── Nginx Proxy Manager   # Internal reverse proxy with clean .home URLs
    │   ├── Watchtower            # Automated container image updates
    │   └── JobSync               # Job application tracker
    ├── Syncthing         # File sync across devices
    ├── Homelab MCP       # Custom MCP server, Claude Code controls the homelab
    └── Claude Code       # AI terminal assistant
```

## Internal DNS + HTTPS

Nginx Proxy Manager runs as a reverse proxy with Pi-hole handling local DNS. All services are accessible via clean `.home` domains with HTTPS. Pi-hole also runs on the Tailscale IP so `.home` domains resolve away from home too.

| URL | Service |
|---|---|
| `https://nextcloud.home` | Nextcloud |
| `https://pihole.home` | Pi-hole |
| `https://portainer.home` | Portainer |
| `https://grafana.home` | Grafana |
| `http://[server-ip]:81` | Nginx Proxy Manager |
| `http://[proxmox-ip]:8006` | Proxmox VE |

## Remote Access

Tailscale VPN mesh across three devices: laptop, phone, Ubuntu VM. Telus uses CGNAT so port forwarding isn't an option. Tailscale creates a WireGuard mesh instead. No open ports, no public exposure. Pi-hole is bound to the Tailscale IP so `.home` domains and ad blocking work from anywhere.

## Backups

Daily automated Proxmox VE backup of the Ubuntu VM at 3am. Compressed with zstd, stored on local Proxmox storage. Keeps last 1 backup.

## Security

* Bitwarden vault holds all homelab credentials. `bw` CLI on the server pulls secrets into env files for scripts.
* SSH is key-only on the Ubuntu server and Proxmox host. Password auth disabled. Root SSH on Proxmox restricted to key auth (`prohibit-password`).
* fail2ban watches sshd on both hosts.
* Proxmox root has TOTP 2FA via Aegis.
* Tailscale-only remote access. CGNAT means no inbound exposure to the internet.

## What I've Learned From This

Linux admin, Proxmox/KVM, Docker, DNS (Pi-hole, split DNS, systemd-resolved), VPN (Tailscale/WireGuard), SSH, reverse proxy (Nginx Proxy Manager), Grafana/Prometheus/cAdvisor monitoring, Discord alerting, Syncthing, Claude Code + MCP, SSL/TLS, LVM disk management

## What's Next

* ~~MCP server integration with Claude Code~~ (done, homelab-mcp v1.6.0)
* ~~Nginx Proxy Manager (internal, over Tailscale)~~ (done, all services on `.home` domains with HTTPS)
* ~~Watchtower for automated container updates~~ (done, running)
* ~~Metasploitable VM for local pentesting~~ (removed — VMs deleted to reclaim resources)
* ~~OnlyOffice document editing in Nextcloud~~ (done)
* ~~Daily backups to Proxmox~~ (done, Proxmox VE native backup, keep last 1)
* ~~Password manager + secret rotation~~ (done, Bitwarden vault + bootstrap script)
* ~~SSH hardening~~ (done, key-only auth + fail2ban on .79 and .76)
* ~~2FA on Proxmox~~ (done, TOTP via Aegis)
* Authelia in front of Grafana, NPM, and Portainer for 2FA on services that don't support it natively
* Backup 3-2-1 — second copy on a different disk plus an offsite copy
* Deploy SIEM (Wazuh or Splunk) for log aggregation and alerting

## Full Writeup

Setup details, problems I ran into, and what I learned: [WRITEUP.md](WRITEUP.md)
