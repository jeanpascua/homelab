# Homelab

Personal homelab built on a Lenovo M710q mini-PC for $110 CAD total. Running Proxmox VE as the hypervisor with Ubuntu Server and Kali Linux VMs.

## Stack

```
Proxmox VE (bare metal)
├── Ubuntu Server VM
│   ├── Docker
│   │   ├── Pi-hole       # Network-wide DNS ad blocking
│   │   ├── Nextcloud     # Self-hosted personal cloud
│   │   ├── Portainer     # Container management UI
│   │   ├── Grafana       # Monitoring dashboards
│   │   ├── Prometheus    # Metrics collection
│   │   └── Node Exporter # System metrics exporter
│   ├── Syncthing         # File sync across devices
│   ├── Claude Code       # AI terminal assistant
│   └── Gemini CLI        # AI terminal assistant (free tier)
└── Kali Linux VM         # Cybersecurity practice
```

## Second Brain

Self-hosted personal knowledge base synced across all devices using Syncthing and Obsidian.

```
Samsung S25 (Obsidian)
        ↕ Syncthing
Ubuntu Server (~/second-brain)
        ↕
Claude Code / Gemini CLI
```

Notes captured on phone via Obsidian sync automatically to the homelab. Claude Code and Gemini CLI have full context over the vault for AI-assisted workflows — job applications, study notes, homelab documentation, and TryHackMe writeups.


## Remote Access

Tailscale VPN mesh across four devices: laptop, phone, Ubuntu VM, Kali VM. Telus uses CGNAT so port forwarding isn't an option. Tailscale creates a WireGuard mesh instead. No open ports, no public exposure.

## Skills Practiced

Linux administration, virtualization (Proxmox/KVM), containerization (Docker), networking (DNS, VPN, SSH), cybersecurity fundamentals (Nmap, Kali), monitoring (Grafana, Prometheus), file sync (Syncthing), AI terminal tooling (Claude Code, Gemini CLI)

## What's Next

* MCP server integration with Claude Code
* Nginx Proxy Manager (internal, over Tailscale)
* Watchtower for automated container updates
* ~~Metasploitable VM for local pentesting~~ — done, actively exploiting with Kali

## Full Writeup

Setup details, problems I ran into, and what I learned: [WRITEUP.md](WRITEUP.md)
