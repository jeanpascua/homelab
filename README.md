# Homelab

Personal homelab built on a Lenovo M710q mini-PC for $110 CAD total. Running Proxmox VE as the hypervisor with Ubuntu Server, Kali Linux, and Metasploitable VMs.

## Stack

```
Proxmox VE (bare metal)
├── Ubuntu Server VM
│   ├── Docker
│   │   ├── Pi-hole               # Network-wide DNS ad blocking
│   │   ├── Nextcloud             # Self-hosted personal cloud
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

## Internal DNS

Nginx Proxy Manager runs as a reverse proxy with Pi-hole handling local DNS. All services are accessible via clean `.home` domains instead of IP:port.

| URL | Service |
|---|---|
| `nextcloud.home` | Nextcloud |
| `pihole.home` | Pi-hole |
| `portainer.home` | Portainer |
| `grafana.home` | Grafana |
| `prometheus.home` | Prometheus |
| `npm.home` | Nginx Proxy Manager |
| `pve.home` | Proxmox VE |

## Remote Access

Tailscale VPN mesh across four devices: laptop, phone, Ubuntu VM, Kali VM. Telus uses CGNAT so port forwarding isn't an option. Tailscale creates a WireGuard mesh instead. No open ports, no public exposure.

## Skills Practiced

Linux administration, virtualization (Proxmox/KVM), containerization (Docker), networking (DNS, VPN, SSH, reverse proxy, Split DNS), cybersecurity fundamentals (Nmap, Kali, Metasploit), monitoring (Grafana, Prometheus), file sync (Syncthing), AI terminal tooling (Claude Code, Gemini CLI), infrastructure automation (custom MCP server, Proxmox API, SSH orchestration)

## What's Next

* ~~MCP server integration with Claude Code~~ — done, homelab-mcp v1.6.0
* ~~Nginx Proxy Manager (internal, over Tailscale)~~ — done, all services on `.home` domains
* ~~Watchtower for automated container updates~~ — done, running
* ~~Metasploitable VM for local pentesting~~ — done, actively exploiting with Kali

## Full Writeup

Setup details, problems I ran into, and what I learned: [WRITEUP.md](WRITEUP.md)
