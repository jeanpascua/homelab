# Homelab

Personal homelab built on a Lenovo M710q mini-PC for $110 CAD total. Running Proxmox VE as the hypervisor with an Ubuntu Server VM hosting the full Docker stack.

## Stack

```
Proxmox VE (bare metal)
├── Ubuntu Server VM (4 cores / 8GB RAM / 120GB disk)
│   ├── Docker
│   │   ├── Pi-hole               # Network-wide DNS ad blocking + .home resolution
│   │   ├── Nextcloud             # Self-hosted personal cloud
│   │   ├── Grafana               # Monitoring dashboards
│   │   ├── Prometheus            # Metrics collection
│   │   ├── Node Exporter         # System metrics exporter
│   │   └── Nginx Proxy Manager   # Internal reverse proxy with clean .home URLs
│   ├── Syncthing         # File sync across devices
│   ├── Homelab MCP       # Custom MCP server — Claude Code controls the homelab
│   └── Claude Code       # AI terminal assistant
```

## Repo Layout

| Path | Contents |
|------|----------|
| `proxmox/` | Proxmox host scripts — VM watchdog, vzdump backup hook, fail2ban, journald, PAM configs. See [proxmox/README.md](proxmox/README.md). |
| `ubuntu-server/` | Ubuntu VM scripts — Docker backup, DNS boot fix, Bitwarden secrets sync, fail2ban, UFW, journald, PAM configs. See [ubuntu-server/README.md](ubuntu-server/README.md). |
| `WRITEUP.md` | Full setup writeup — decisions, problems, what I learned. |

## Internal DNS + HTTPS

Nginx Proxy Manager runs as a reverse proxy with Pi-hole handling local DNS. All services are accessible via clean `.home` domains with HTTPS. Pi-hole also runs on the Tailscale IP so `.home` domains resolve away from home too.

| URL | Service |
|---|---|
| `https://nextcloud.home` | Nextcloud |
| `https://pihole.home` | Pi-hole |
| `https://grafana.home` | Grafana |
| `http://[server-ip]:81` | Nginx Proxy Manager |
| `http://[proxmox-ip]:8006` | Proxmox VE |

## Remote Access

Tailscale VPN mesh across laptop, phone, and the Ubuntu VM. Telus uses CGNAT so port forwarding isn't an option. Tailscale creates a WireGuard mesh instead. No open ports, no public exposure. Pi-hole is bound to the Tailscale IP so `.home` domains and ad blocking work from anywhere.

## Skills Practiced

Linux administration, virtualization (Proxmox/KVM), containerization (Docker), networking (DNS, VPN, SSH, reverse proxy, Split DNS, systemd-resolved), monitoring and alerting (Grafana, Prometheus, Discord webhooks), file sync (Syncthing), AI terminal tooling (Claude Code), infrastructure automation (custom MCP server, Proxmox API, SSH orchestration), SSL/TLS (self-signed certs, CA installation)

## Full Writeup

Setup details, problems I ran into, and what I learned: [WRITEUP.md](WRITEUP.md)
