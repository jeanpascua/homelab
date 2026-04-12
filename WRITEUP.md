# Homelab Writeup

## Overview

I built this to get real hands-on infrastructure experience outside of coursework. The kind you can't get from reading about it.

Lenovo M710q mini-PC, $110 CAD total. The goal was to actually run Linux, VMs, containers, and networking tools in a real environment instead of a cloud sandbox.

---

## Hardware

- **Server:** Lenovo M710q mini-PC (Intel Core i5-7500T, 8GB DDR4, 256GB NVMe SSD) : $85
- **Networking:** TP-Link AV1000 powerline adapter kit : $25

The mini-PC doesn't have built-in WiFi reliable enough for a server. The Proxmox web interface kept dropping and VMs were having network issues. Powerline adapters use the house's existing electrical wiring to carry the network signal. One adapter near the router, one at the server. Stable wired connection without running ethernet through the walls.

---

## Software Stack

```
Proxmox VE (Hypervisor, bare metal)
├── Ubuntu Server VM
│   └── Docker
│       ├── Pi-hole         # DNS-level ad blocking
│       ├── Nextcloud       # Self-hosted personal cloud storage
│       ├── Portainer       # Docker container management UI
│       ├── Grafana         # Monitoring dashboards
│       ├── Prometheus      # Metrics collection
│       └── Node Exporter   # System metrics exporter
└── Kali Linux VM           # Cybersecurity practice environment
```

---

## Setup

### Proxmox VE

Flashed Proxmox onto a USB drive and installed it bare metal on the M710q. Enabled Intel VT-x in BIOS first so VMs run with hardware acceleration. Proxmox sits on top of Debian and gives you a web UI for managing VMs.

Provisioned two VMs: Ubuntu Server for running services and Kali for security practice. Both are headless. After initial setup, everything is managed over SSH.

### Docker on Ubuntu Server

Installed Docker on the Ubuntu VM. Running three containers:

- **Pi-hole** - DNS sinkhole. Blocks ads and trackers at the network level before they reach any device.
- **Nextcloud** - self-hosted file storage. Same idea as Google Drive but on my own hardware.
- **Portainer** - web UI for managing containers, images, and volumes.

### Tailscale VPN

Tailscale runs on all four devices: laptop, phone, Ubuntu VM, and Kali VM. It uses WireGuard under the hood and creates a mesh VPN so everything can reach each other regardless of what network I'm on.

This ended up being the remote access solution after the original plan didn't work out (see below).

### Kali Linux VM

Second VM for cybersecurity practice. Used alongside TryHackMe rooms. Running tools like Nmap to scan the local network, discovering hosts, open ports, running services.

### Monitoring

Set up Grafana and Prometheus to monitor the server. Grafana is the dashboard, Prometheus collects the metrics, and Node Exporter is what actually pulls the system data like CPU, memory, disk, and network.

Deployed all three as a stack through Portainer. The stack keeps them grouped together and makes it easy to manage.

The tricky part was the dashboard. Grafana has a library of community dashboards you can import by ID. Dashboard 1860 is the standard one for Node Exporter. The problem was Grafana couldn't reach grafana.com from inside the container to download it. Had to download the JSON file on my laptop and upload it manually instead.

Once that was sorted the dashboard loaded with live data from the server.

---

## Problems I Ran Into

### WiFi Was Unreliable

No built-in WiFi on the M710q. A USB adapter worked but kept causing dropped connections to the Proxmox interface and instability in the VMs. Powerline adapters fixed it immediately.

### CGNAT Broke Port Forwarding

The original plan was Nginx Proxy Manager as a reverse proxy for clean domain names instead of typing IP:port every time. That requires opening ports 80 and 443 on the router so external traffic can reach the server.

Telus uses CGNAT (Carrier-Grade NAT) on residential connections. The public IP on the modem is shared across multiple customers. Inbound traffic never reaches your specific connection. Port forwarding doesn't work.

Tailscale was the fix. Instead of exposing ports publicly, it creates a private encrypted tunnel between devices using WireGuard. I can reach Nextcloud, Pi-hole, and Portainer from anywhere through Tailscale. No port forwarding needed, no exposure to the public internet.

---

## What I Learned

- How to provision and manage VMs on a bare metal hypervisor
- How containerization works in practice, isolated services on a single VM
- How DNS works at the network level through Pi-hole
- How CGNAT works and why ISPs use it
- How WireGuard-based VPNs build mesh networks without a central server
- How to diagnose network issues and find workarounds
- Linux administration through SSH on headless servers
- How to enable hardware virtualization in BIOS
- How to set up server monitoring with Grafana and Prometheus

---

## What's Next

- [x] Grafana + Prometheus for monitoring and dashboards
- [ ] Nginx Proxy Manager internally (over Tailscale only)
- [ ] Watchtower for automated container updates
- [ ] Metasploitable VM for local pentesting
- [ ] Document TryHackMe rooms done with the Kali VM
