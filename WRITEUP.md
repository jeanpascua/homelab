# Homelab Writeup

## Overview

I built this to get real hands-on infrastructure experience outside of coursework — the kind you can't get from reading about it.

Built a personal homelab on a Lenovo M710q mini-PC for a total hardware cost of **$110 CAD**. The goal was to get hands-on experience with Linux administration, virtualization, containerization, networking, and cybersecurity in a real environment rather than just a cloud sandbox.

---

## Hardware

- **Server:** Lenovo M710q mini-PC (Intel Core i5-7500T, 8GB DDR4, 256GB NVMe SSD) — $85
- **Networking:** TP-Link AV1000 powerline adapter kit — $25

The powerline adapter solved the first problem I ran into. The mini-PC doesn't have built-in WiFi reliable enough for a server — the Proxmox web interface kept dropping and VMs were having network issues. Powerline uses the existing electrical wiring in the house to carry the network signal, so I plugged one adapter into a wall outlet near the router and ran the other to the mini-PC. Stable wired connection without running ethernet cable through the walls.

---

## Software Stack

```
Proxmox VE (Hypervisor — bare metal)
├── Ubuntu Server VM
│   └── Docker
│       ├── Pi-hole         # DNS-level ad blocking
│       ├── Nextcloud       # Self-hosted personal cloud storage
│       └── Portainer       # Docker container management UI
└── Kali Linux VM           # Cybersecurity practice environment
```

---

## Setup Process

### 1. Proxmox VE

Flashed Proxmox VE onto a USB drive and installed it directly on the Lenovo M710q bare metal. Before booting into the installer, I enabled Intel VT-x (hardware virtualization) in the BIOS to allow Proxmox to run fully accelerated VMs. Proxmox runs on top of Debian and exposes a web-based interface for creating and managing VMs.

From there I provisioned two VMs — Ubuntu Server for running services, and Kali Linux for security practice. Both are administered entirely over SSH in a headless environment (no monitor or keyboard attached after initial setup).

### 2. Docker on Ubuntu Server

Installed Docker on the Ubuntu Server VM and used Portainer to manage containers through a web UI. Running three containers:

- **Pi-hole** — acts as a DNS sinkhole, blocking ads and trackers at the network level before they even reach devices
- **Nextcloud** — self-hosted file storage and sync, similar to Google Drive but running on my own hardware
- **Portainer** — web UI for managing Docker containers, images, and volumes

### 3. Tailscale VPN

Set up Tailscale on all four devices — laptop, phone, Ubuntu VM, and Kali VM. Tailscale uses WireGuard under the hood and creates a mesh VPN so all devices can reach each other securely regardless of what network they're on.

This became the remote access solution after the original plan ran into a wall.

### 4. Kali Linux VM

Set up Kali Linux as a second VM for cybersecurity practice. Used it alongside TryHackMe rooms to run tools like Nmap for network reconnaissance — scanning the local network to discover hosts, open ports, and running services.

---

## Problems I Ran Into

### WiFi Was Unreliable
The mini-PC doesn't have a built-in WiFi adapter. Running it wireless via USB adapter was causing dropped connections to the Proxmox web interface and instability in the VMs. Solved it by getting a TP-Link AV1000 powerline adapter kit — one unit plugs into a wall outlet near the router, the other near the server, and they communicate through the house's electrical wiring. Immediate improvement in stability.

### Nginx Proxy Manager Didn't Work — Telus Uses CGNAT
The original plan was to use Nginx Proxy Manager as a reverse proxy to access services through clean domain names instead of IP:port combinations. This requires port forwarding — opening ports 80 and 443 on the router so external traffic can reach the server.

Telus uses CGNAT (Carrier-Grade NAT) on residential connections, which means the public IP address assigned to the modem is shared across multiple customers. Port forwarding doesn't work because inbound traffic never reaches your specific connection. Nginx Proxy Manager was effectively useless for external access in this setup.

The workaround was Tailscale. Instead of exposing ports publicly, Tailscale creates a private encrypted tunnel between my devices using WireGuard. I can access Nextcloud, Pi-hole, and Portainer from anywhere by connecting through Tailscale — no port forwarding needed, no exposure to the public internet.

---

## What I Learned

- How to provision and manage VMs on a bare metal hypervisor
- How containerization works in practice — running isolated services on a single VM
- How DNS works at a network level through Pi-hole configuration
- How CGNAT works and why residential ISPs use it
- How WireGuard-based VPNs create mesh networks without centralized servers
- How to diagnose network connectivity issues and find practical workarounds
- Linux system administration through SSH on headless servers
- How to enable hardware virtualization (Intel VT-x) in BIOS for VM acceleration

---

## What's Next

- [ ] Set up Grafana + Prometheus for system monitoring and dashboards
- [ ] Add Nginx Proxy Manager internally (accessible over Tailscale only)
- [ ] Automate container updates with Watchtower
- [ ] Deploy Metasploitable VM for local penetration testing practice
- [ ] Document TryHackMe rooms completed using the Kali VM

---

## Network Details

| Device | Local IP | Tailscale IP |
|--------|----------|--------------|
| Proxmox | 192.168.1.76 | — |
| Ubuntu Server | 192.168.1.79 | 100.110.180.92 |
| Kali Linux | 192.168.1.80 | 100.78.242.26 |
