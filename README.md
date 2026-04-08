# Homelab

A personal home lab built to learn Linux administration, virtualization, containerization, and cybersecurity fundamentals hands-on.

---

## Hardware

- Bare metal server running Proxmox VE as the hypervisor

---

## Infrastructure Overview

```
Proxmox VE (Hypervisor)
├── Ubuntu Server VM
│   └── Docker
│       ├── Pi-hole         # DNS-level ad blocking
│       ├── Nextcloud       # Self-hosted personal cloud
│       └── Portainer       # Container management UI
└── Kali Linux VM           # Security practice environment
```

---

## What's Running

### Ubuntu Server + Docker
Core services are containerized and managed through Portainer.

| Container | Purpose |
|-----------|---------|
| Pi-hole | Network-wide DNS ad blocker |
| Nextcloud | Self-hosted file storage and sync |
| Portainer | Docker container management via web UI |

### Kali Linux VM
Used for cybersecurity practice including network reconnaissance with Nmap, exploring common attack surfaces, and understanding how defenses work from the attacker's perspective.

### Remote Access
Secure remote access configured via **Tailscale VPN**, allowing connection to all lab services from any device or network without exposing ports publicly.

All server administration done over **SSH in a headless environment** — no desktop GUI.

---

## Skills Practiced

- **Virtualization** — Proxmox VE, KVM, managing multiple VMs simultaneously
- **Containerization** — Docker, Docker Compose, Portainer
- **Linux Administration** — Ubuntu Server, Kali Linux, headless SSH admin
- **Networking** — DNS configuration, VPN setup, network reconnaissance (Nmap)
- **Cybersecurity** — Attack surface analysis, secure remote access, network monitoring

---

## What I Learned

- How to segment services using VMs and containers to isolate workloads
- How Pi-hole intercepts DNS queries to filter traffic at the network level
- How Tailscale uses WireGuard under the hood to create a zero-config mesh VPN
- How to navigate and administer Linux systems entirely through the command line
- How to use Nmap for host discovery and port scanning in a controlled environment

---

## What's Next

- [ ] Set up a monitoring stack (Grafana + Prometheus)
- [ ] Automate container updates with Watchtower
- [ ] Add a reverse proxy (Nginx Proxy Manager or Traefik)
- [ ] Start documenting TryHackMe/CTF writeups in a separate repo

---

## Connect

- LinkedIn: [linkedin.com/in/jeanpascua](https://linkedin.com/in/jeanpascua)
- GitHub: [github.com/jeanpascua](https://github.com/jeanpascua)
