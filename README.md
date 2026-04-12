# Homelab

Personal homelab built on a Lenovo M710q mini-PC for $110 CAD total. Running Proxmox VE as the hypervisor with Ubuntu Server and Kali Linux VMs.

## Stack

```
Proxmox VE (bare metal)
├── Ubuntu Server VM
│   └── Docker
│       ├── Pi-hole       # Network-wide DNS ad blocking
│       ├── Nextcloud     # Self-hosted personal cloud
│       ├── Portainer     # Container management UI
│       ├── Grafana       # Monitoring dashboards
│       ├── Prometheus    # Metrics collection
│       └── Node Exporter # System metrics exporter
└── Kali Linux VM         # Cybersecurity practice
```

## Remote Access

Tailscale VPN mesh across four devices: laptop, phone, Ubuntu VM, Kali VM. Telus uses CGNAT so port forwarding isn't an option. Tailscale creates a WireGuard mesh instead. No open ports, no public exposure.

## Skills Practiced

Linux administration, virtualization (Proxmox/KVM), containerization (Docker), networking (DNS, VPN, SSH), cybersecurity fundamentals (Nmap, Kali), monitoring (Grafana, Prometheus)

## What's Next

- [x] Grafana + Prometheus monitoring
- [ ] Nginx Proxy Manager (internal, over Tailscale)
- [ ] Watchtower for automated container updates
- [ ] Metasploitable VM for local pentesting

## Full Writeup

Setup details, problems I ran into, and what I learned: [WRITEUP.md](./WRITEUP.md)
