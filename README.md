# Homelab

Personal homelab built on a Lenovo M710q mini-PC for $110 CAD total. Running Proxmox VE as the hypervisor with Ubuntu Server, Kali Linux, and Metasploitable VMs.

## Stack

```
Proxmox VE (bare metal)
├── Ubuntu Server VM (4 cores / 8GB RAM / 120GB disk)
│   ├── Docker
│   │   ├── Pi-hole               # Network-wide DNS ad blocking + .home resolution
│   │   ├── Nextcloud             # Self-hosted personal cloud
│   │   ├── OnlyOffice            # Document editing integrated with Nextcloud
│   │   ├── Portainer             # Container management UI
│   │   ├── Grafana               # Monitoring dashboards
│   │   ├── Prometheus            # Metrics collection
│   │   ├── Node Exporter         # System metrics exporter
│   │   ├── Nginx Proxy Manager   # Internal reverse proxy with clean .home URLs
│   │   └── Watchtower            # Automated container image updates
│   ├── Syncthing         # File sync across devices
│   ├── Homelab MCP       # Custom MCP server — Claude Code controls the homelab
│   ├── Claude Code       # AI terminal assistant
│   └── Gemini CLI        # AI terminal assistant (free tier)
├── Kali Linux VM         # Cybersecurity practice
└── Metasploitable VM     # Intentionally vulnerable target for local pentesting
```

## Internal DNS + HTTPS

Nginx Proxy Manager runs as a reverse proxy with Pi-hole handling local DNS. All services are accessible via clean `.home` domains with HTTPS. Pi-hole also runs on the Tailscale IP so `.home` domains resolve away from home too.

| URL | Service |
|---|---|
| `https://nextcloud.home` | Nextcloud |
| `https://pihole.home` | Pi-hole |
| `https://portainer.home` | Portainer |
| `https://grafana.home` | Grafana |
| `http://192.168.1.79:81` | Nginx Proxy Manager |
| `http://192.168.1.76:8006` | Proxmox VE |

## Remote Access

Tailscale VPN mesh across four devices: laptop, phone, Ubuntu VM, Kali VM. Telus uses CGNAT so port forwarding isn't an option. Tailscale creates a WireGuard mesh instead. No open ports, no public exposure. Pi-hole is bound to the Tailscale IP so `.home` domains and ad blocking work from anywhere.

## Backups

Daily automated backups of all Docker volumes to Proxmox at 3am. Keeps 7 days of history. Volumes backed up: Nextcloud data, Pi-hole config, NPM config and certs.

## Skills Practiced

Linux administration, virtualization (Proxmox/KVM), containerization (Docker), networking (DNS, VPN, SSH, reverse proxy, Split DNS, systemd-resolved), cybersecurity fundamentals (Nmap, Kali, Metasploit), monitoring (Grafana, Prometheus), file sync (Syncthing), AI terminal tooling (Claude Code, Gemini CLI), infrastructure automation (custom MCP server, Proxmox API, SSH orchestration), SSL/TLS (self-signed certs, CA installation)

## What's Next

* ~~MCP server integration with Claude Code~~ — done, homelab-mcp v1.6.0
* ~~Nginx Proxy Manager (internal, over Tailscale)~~ — done, all services on `.home` domains with HTTPS
* ~~Watchtower for automated container updates~~ — done, running
* ~~Metasploitable VM for local pentesting~~ — done, actively exploiting with Kali
* ~~OnlyOffice document editing in Nextcloud~~ — done
* ~~Daily backups to Proxmox~~ — done, 7-day retention
* Document TryHackMe rooms done with the Kali VM

## Full Writeup

Setup details, problems I ran into, and what I learned: [WRITEUP.md](WRITEUP.md)
