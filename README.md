# Homelab

Personal homelab built on a Lenovo M710q mini-PC ($110 total). Running Proxmox VE as the hypervisor with Ubuntu Server and Kali Linux VMs.

## Stack

```
Proxmox VE (bare metal)
├── Ubuntu Server VM
│   └── Docker
│       ├── Pi-hole       # Network-wide DNS ad blocking
│       ├── Nextcloud     # Self-hosted personal cloud
│       └── Portainer     # Container management UI
└── Kali Linux VM         # Cybersecurity practice
```

## Remote Access

Tailscale VPN mesh across four devices — laptop, phone, Ubuntu VM, Kali VM.

## Skills

Linux administration, virtualization (Proxmox/KVM), containerization (Docker), networking (DNS, VPN, SSH), cybersecurity fundamentals (Nmap, Kali)

## What's Next

- [ ] Grafana + Prometheus monitoring
- [ ] Nginx Proxy Manager (internal, over Tailscale)
- [ ] Watchtower for automated container updates
- [ ] Metasploitable VM for local pentesting

## Full Writeup

For setup details, problems I ran into, and what I learned — see [WRITEUP.md](./WRITEUP.md)
