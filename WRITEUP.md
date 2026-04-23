# Homelab Writeup

## Overview

I built this to get real hands-on infrastructure experience outside of coursework. The kind you can't get from reading about it.

Lenovo M710q mini-PC, $110 CAD total. Runs Proxmox as the hypervisor with Ubuntu Server and Kali Linux VMs. Everything managed over SSH.

---

## Hardware

* **Server:** Lenovo M710q mini-PC (Intel Core i5-7500T, 8GB DDR4, 256GB NVMe SSD) : $85
* **Networking:** TP-Link AV1000 powerline adapter kit : $25

The mini-PC has no built-in WiFi. A USB adapter worked at first but kept dropping the Proxmox interface and causing VM instability. Powerline adapters use the house's electrical wiring to carry the network signal — one near the router, one at the server. Stable wired connection without running ethernet through the walls.

---

## Software Stack

```
Proxmox VE (Hypervisor, bare metal)
├── Ubuntu Server VM
│   ├── Docker
│   │   ├── Pi-hole               # DNS-level ad blocking
│   │   ├── Nextcloud             # Self-hosted personal cloud storage
│   │   ├── Portainer             # Docker container management UI
│   │   ├── Grafana               # Monitoring dashboards
│   │   ├── Prometheus            # Metrics collection
│   │   ├── Node Exporter         # System metrics exporter
│   │   └── Nginx Proxy Manager   # Internal reverse proxy with .home domains
│   ├── Syncthing           # File sync across devices
│   ├── Claude Code         # AI terminal assistant
│   └── Gemini CLI          # AI terminal assistant (free tier)
├── Kali Linux VM           # Cybersecurity practice environment
└── Metasploitable VM       # Intentionally vulnerable target for local pentesting
```

---

## Setup

### Proxmox VE

Flashed Proxmox onto a USB drive and installed it bare metal on the M710q. Had to enable Intel VT-x in BIOS first so VMs run with hardware acceleration. Proxmox sits on top of Debian and gives you a web UI for managing VMs.

Provisioned three VMs: Ubuntu Server for running services, Kali for security practice, and Metasploitable as a local pentesting target. All three are headless — after initial setup everything is managed over SSH.

### Docker on Ubuntu Server

Installed Docker on the Ubuntu VM. Running seven containers:

* **Pi-hole** - DNS sinkhole. Blocks ads and trackers at the network level before they reach any device.
* **Nextcloud** - self-hosted file storage. Same idea as Google Drive but on my own hardware.
* **Portainer** - web UI for managing containers, images, and volumes.
* **Grafana** - monitoring dashboards for the server.
* **Prometheus** - metrics collection backend for Grafana.
* **Node Exporter** - pulls system metrics from the host (CPU, memory, disk, network).
* **Nginx Proxy Manager** - reverse proxy that maps `.home` domains to each container.

### Tailscale VPN

Needed remote access without opening ports. Telus uses CGNAT so port forwarding doesn't work — the public IP on the modem is shared and inbound traffic never reaches your connection. Tailscale was the fix. It creates a WireGuard mesh between all four devices: laptop, phone, Ubuntu VM, Kali VM. Everything can reach each other regardless of what network I'm on. No open ports, no public exposure.

### Kali Linux VM

Second VM for cybersecurity practice. Used alongside TryHackMe rooms. Running tools like Nmap to scan the local network — discovering hosts, open ports, running services. Also set up Metasploitable as a local target to practice exploiting with Metasploit without touching anything outside my own network.

### Monitoring

Wanted visibility into what the server was actually doing. Set up Grafana, Prometheus, and Node Exporter as a stack through Portainer. Node Exporter pulls system metrics, Prometheus collects them, Grafana displays them.

The dashboard was the annoying part. Grafana has a community dashboard library you can import by ID — 1860 is the standard Node Exporter one. But Grafana couldn't reach grafana.com from inside the container to download it. Had to download the JSON on my laptop and upload it manually.

Once that was sorted, live CPU, memory, disk, and network data showing up on the dashboard.

### Nginx Proxy Manager and Internal DNS

Typing `192.168.1.79:8080` to reach Nextcloud gets old fast. Set up Nginx Proxy Manager as a reverse proxy so every service is accessible by a clean `.home` domain instead of an IP and port.

Pi-hole handles the local DNS. Each `.home` domain gets a DNS record pointing to `192.168.1.79` where NPM is running. NPM forwards the request to the right container.

| URL | Service | Port |
|---|---|---|
| `nextcloud.home` | Nextcloud | 8080 |
| `pihole.home` | Pi-hole | 8053 |
| `portainer.home` | Portainer | 9000 |
| `grafana.home` | Grafana | 3000 |
| `prometheus.home` | Prometheus | 9090 |
| `npm.home` | Nginx Proxy Manager | 81 |
| `pve.home` | Proxmox VE | 8006 |

Deployed NPM as a new Docker stack through Portainer on ports 80, 81, and 443. Pi-hole was already running so no extra DNS server needed — just added the local DNS records in the Pi-hole admin panel.

### Problems I Ran Into

**Windows ignoring the Pi-hole DNS** - Set DNS manually in Windows network settings but the laptop kept using Telus DNS over IPv6. Fix was disabling IPv6 on the network adapter to force IPv4, which picked up Pi-hole.

**Nextcloud blocking the new domain** - Nextcloud has a `trusted_domains` whitelist. Accessing it from `nextcloud.home` threw an "untrusted domain" error. Fixed by running `docker exec nextcloud php occ config:system:set trusted_domains 3 --value=nextcloud.home` to add it.

**Proxmox authentication breaking through the proxy** - Proxmox uses ticket-based auth with cookies tied to the origin. Proxying it through NPM caused a "401: no ticket" error after login. Full reverse proxy for Proxmox is complex. Simpler fix was a redirect — `pve.home` redirects straight to `https://192.168.1.76:8006` using `return 301` in the NPM nginx config. Proxmox handles auth itself, no proxy in the way.

---

## Second Brain and AI Terminal Setup

The homelab was running but I wasn't really using it. Services just sitting there. I wanted it to actually be part of my workflow — something I interact with every day, not just maintain.

### The Problem with Browser AI Tools

Every new chat starts from scratch. You explain your background, your project, what you're working on — and next session it's gone. I wanted something with memory that lives on my own hardware.

### AI Terminal Tools

Installed two AI CLI tools directly on the Ubuntu Server:

* **Gemini CLI** - Google's free terminal AI, installed via npm
* **Claude Code** - Anthropic's terminal AI, requires Claude Pro

Both read a context file at startup so they already know who I am, what my background is, and where everything is stored. No re-explaining every session. Claude Code also has a job search agent at `.claude/agents/job-search-coach.md` for resume writing, cover letters, and interview prep.

### Second Brain Folder

Everything lives in `~/second-brain` on the Ubuntu Server:

```
~/second-brain/
├── CLAUDE.md       # Claude Code context file
├── GEMINI.md       # Gemini CLI context file
├── career/         # Resume, cover letters, job applications
├── homelab/        # Infrastructure notes and configs
├── school/         # Course notes and assignments
├── tryhackme/      # Writeups and learning notes
└── ideas/          # Capture notes from phone
```

### Syncthing

Needed the folder on all three devices — phone, laptop, and server. Installed Syncthing on all three. Syncs automatically over the local network whenever devices are online. No cloud, no third party, stays on my own hardware.

```
Samsung S25 (Obsidian)
        ↕ Syncthing (TCP LAN)
Ubuntu Server (~/second-brain)
        ↕ Syncthing (TCP LAN)
Windows Laptop
```

### Obsidian

Installed Obsidian on the S25 and Windows laptop pointing at the synced folder. Good mobile editor, graph view, search. The workflow is: write something on my phone, Syncthing pushes it to the server, Claude Code has it next session.

### Problems I Ran Into

**npm not found** - Ubuntu's apt repo ships an outdated version of Node. Used nvm instead to install the LTS version, then installed the AI CLI tools through that.

**SSH tunnel port conflict** - Accessing the homelab's Syncthing web UI required SSH port forwarding. Once Syncthing was also installed on Windows, both instances tried to use port 8384. Used `-L 8385:localhost:8384` to forward to a different local port instead.

**Samsung power saving killing Syncthing** - Android's aggressive battery optimization was stopping Syncthing from running in the background. Fixed by setting Syncthing to unrestricted battery usage in Android settings.

---

## Tailscale Split DNS for .home Domains Away from Home

The `.home` domains work at home because Windows DNS points at Pi-hole on the local IP. The problem is leaving home — Pi-hole isn't reachable and `.home` stops resolving.

First attempt was setting Windows DNS manually to Pi-hole's Tailscale IP. `nslookup` worked but the Windows DNS resolver and browsers couldn't reach it — regular internet broke. Tailscale handles DNS queries differently than direct queries, so pointing Windows at a Tailscale IP doesn't work the same way.

The fix was Tailscale's Split DNS feature in the admin console. Added Pi-hole as a nameserver scoped to the `home` domain. Tailscale automatically pushes this DNS rule to all connected devices — no manual settings needed on Windows.

* Queries for `*.home` go through Tailscale to Pi-hole
* Everything else uses normal system DNS, untouched

Windows DNS stays on automatic. Brave's secure DNS stays off. `.home` domains work at home and away from home as long as Tailscale is connected.

---

## What I Learned

* Provisioning and managing VMs on a bare metal hypervisor
* How containerization works in practice — isolated services on a single VM
* How DNS works at the network level, both for blocking and for local resolution
* How CGNAT works and why port forwarding doesn't work on residential Telus
* How WireGuard-based VPNs build mesh networks without a central server
* Diagnosing network issues and finding workarounds when the obvious solution doesn't work
* Linux administration through SSH on headless servers
* How to enable hardware virtualization in BIOS
* Setting up server monitoring with Grafana, Prometheus, and Node Exporter
* Peer-to-peer file sync with Syncthing across three devices
* How AI terminal tools work and building persistent context workflows
* Managing Node versions on Linux with nvm
* How reverse proxies work and setting up clean internal domains with NPM and Pi-hole
* Why CGNAT blocks external proxying and how to work around it internally
* How Proxmox auth breaks behind a reverse proxy and the redirect workaround
* How Tailscale Split DNS extends local DNS to remote devices without breaking regular internet

---

## What's Next

* MCP server integration with Claude Code (GitHub, filesystem, web search)
* ~~Nginx Proxy Manager internally~~ — done, all services on `.home` domains
* Watchtower for automated container updates
* ~~Metasploitable VM for local pentesting~~ — done, actively exploiting with Kali
* Document TryHackMe rooms done with the Kali VM
