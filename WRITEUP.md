# Homelab Writeup

## Overview

I built this to get real hands-on infrastructure experience outside of coursework. The kind you can't get from reading about it.

Lenovo M710q mini-PC, $110 CAD total. Runs Proxmox as the hypervisor with Ubuntu Server, Kali Linux, and Metasploitable VMs. Everything managed over SSH.

---

## Hardware

* **Server:** Lenovo M710q mini-PC (Intel Core i5-7500T, 8GB DDR4, 256GB NVMe SSD) : $85
* **Networking:** TP-Link AV1000 powerline adapter kit : $25

The mini-PC has no built-in WiFi. A USB adapter worked at first but kept dropping the Proxmox interface and causing VM instability. Powerline adapters use the house's electrical wiring to carry the network signal — one near the router, one at the server. Stable wired connection without running ethernet through the walls.

---

## Software Stack

```
Proxmox VE (Hypervisor, bare metal)
├── Ubuntu Server VM (4 cores / 8GB RAM / 120GB disk)
│   ├── Docker
│   │   ├── Pi-hole               # DNS-level ad blocking + .home resolution
│   │   ├── Nextcloud             # Self-hosted personal cloud storage
│   │   ├── OnlyOffice            # Document editing integrated with Nextcloud
│   │   ├── Portainer             # Docker container management UI
│   │   ├── Grafana               # Monitoring dashboards
│   │   ├── Prometheus            # Metrics collection
│   │   ├── Node Exporter         # System metrics exporter
│   │   ├── Nginx Proxy Manager   # Internal reverse proxy with .home domains
│   │   └── Watchtower            # Automated container image updates
│   ├── Syncthing           # File sync across devices
│   ├── Homelab MCP         # Custom MCP server — Claude Code controls the homelab
│   └── Claude Code         # AI terminal assistant
├── Kali Linux VM           # Cybersecurity practice environment
└── Metasploitable VM       # Intentionally vulnerable target for local pentesting
```

---

## Setup

### Proxmox VE

Flashed Proxmox onto a USB drive and installed it bare metal on the M710q. Had to enable Intel VT-x in BIOS first so VMs run with hardware acceleration. Proxmox sits on top of Debian and gives you a web UI for managing VMs.

Provisioned three VMs: Ubuntu Server for running services, Kali for security practice, and Metasploitable as a local pentesting target. All three are headless — after initial setup everything is managed over SSH.

### Docker on Ubuntu Server

Installed Docker on the Ubuntu VM. Running nine containers:

* **Pi-hole** - DNS sinkhole. Blocks ads and trackers at the network level before they reach any device.
* **Nextcloud** - self-hosted file storage. Same idea as Google Drive but on my own hardware.
* **OnlyOffice** - document editing server integrated with Nextcloud. Edit .docx, .xlsx, and .pptx directly in the browser.
* **Portainer** - web UI for managing containers, images, and volumes.
* **Grafana** - monitoring dashboards for the server.
* **Prometheus** - metrics collection backend for Grafana.
* **Node Exporter** - pulls system metrics from the host (CPU, memory, disk, network).
* **Nginx Proxy Manager** - reverse proxy that maps `.home` domains to each container.
* **Watchtower** - monitors running containers and automatically pulls updated images when they're available. No manual `docker pull` needed.

### Tailscale VPN

Needed remote access without opening ports. Telus uses CGNAT so port forwarding doesn't work — the public IP on the modem is shared and inbound traffic never reaches your connection. Tailscale was the fix. It creates a WireGuard mesh between all four devices: laptop, phone, Ubuntu VM, Kali VM. Everything can reach each other regardless of what network I'm on. No open ports, no public exposure.

### Kali Linux VM

Second VM for cybersecurity practice. Used alongside TryHackMe rooms. Running tools like Nmap to scan the local network — discovering hosts, open ports, running services. Also set up Metasploitable as a local target to practice exploiting with Metasploit without touching anything outside my own network.

### Monitoring

Wanted visibility into what the server was actually doing. Set up Grafana, Prometheus, and Node Exporter as a stack through Portainer. Node Exporter pulls system metrics, Prometheus collects them, Grafana displays them.

Prometheus runs with a config file that tells it to scrape metrics from Node Exporter every 15 seconds. Grafana connects to Prometheus as a data source, then displays everything on a dashboard.

The dashboard was the annoying part. Grafana has a community dashboard library you can import by ID — 1860 is the standard Node Exporter one. But Grafana couldn't reach grafana.com from inside the container to download it. Had to download the JSON separately and import it via the Grafana API instead.

Once that was sorted, live CPU, memory, disk, and network data showing up on the dashboard.

### Nginx Proxy Manager and Internal DNS

Typing `[server-ip]:8080` to reach Nextcloud gets old fast. Set up Nginx Proxy Manager as a reverse proxy so every service is accessible by a clean `.home` domain instead of an IP and port.

Pi-hole handles the local DNS. Each `.home` domain gets a DNS record pointing to `[server-ip]` where NPM is running. NPM forwards the request to the right container.

| URL | Service | Port |
|---|---|---|
| `nextcloud.home` | Nextcloud | 8080 |
| `pihole.home` | Pi-hole | 8053 |
| `portainer.home` | Portainer | 9000 |
| `grafana.home` | Grafana | 3000 |
| `pve.home` | Proxmox VE (redirect) | 8006 |

Deployed NPM as a new Docker stack through Portainer on ports 80, 81, and 443. Pi-hole was already running so no extra DNS server needed — just added the local DNS records in the Pi-hole admin panel.

### Problems I Ran Into

**Windows ignoring the Pi-hole DNS** - Set DNS manually in Windows network settings but the laptop kept using Telus DNS over IPv6. Fix was disabling IPv6 on the network adapter to force IPv4, which picked up Pi-hole.

**Nextcloud blocking the new domain** - Nextcloud has a `trusted_domains` whitelist. Accessing it from `nextcloud.home` threw an "untrusted domain" error. Fixed by running `docker exec nextcloud php occ config:system:set trusted_domains 3 --value=nextcloud.home` to add it.

**Proxmox authentication breaking through the proxy** - Proxmox uses ticket-based auth with cookies tied to the origin. Proxying it through NPM caused a "401: no ticket" error after login. Full reverse proxy for Proxmox is complex. Simpler fix was a redirect — `pve.home` redirects straight to `https://[proxmox-ip]:8006` using `return 301` in the NPM nginx config. Proxmox handles auth itself, no proxy in the way.

---

## Second Brain and AI Terminal Setup

The homelab was running but I wasn't really using it. Services just sitting there. I wanted it to actually be part of my workflow — something I interact with every day, not just maintain.

### The Problem with Browser AI Tools

Every new chat starts from scratch. You explain your background, your project, what you're working on — and next session it's gone. I wanted something with memory that lives on my own hardware.

### AI Terminal Tools

Installed Claude Code directly on the Ubuntu Server. It reads a context file at startup so it already knows who I am, what my background is, and where everything is stored. No re-explaining every session.

### Second Brain Folder

Everything lives in `~/Sync/second-brain` on the Ubuntu Server:

```
~/Sync/second-brain/
├── CLAUDE.md           # Claude Code context file
├── career/             # Resume, cover letters, job applications
├── school/             # Course notes and assignments
└── ideas/              # Capture notes from phone
```

### Syncthing

Needed the folder on all three devices — phone, laptop, and server. Installed Syncthing on all three. Syncs automatically over the local network whenever devices are online. No cloud, no third party, stays on my own hardware.

```
Samsung S25 (Obsidian)
        ↕ Syncthing (TCP LAN)
Ubuntu Server (~/Sync/second-brain)
        ↕ Syncthing (TCP LAN)
Windows Laptop
```

### Obsidian

Installed Obsidian on the S25 and Windows laptop pointing at the synced folder. Good mobile editor, graph view, search. The workflow is: write something on my phone, Syncthing pushes it to the server, Claude Code has it next session.

### Problems I Ran Into

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

## MCP Server Integration

The second brain setup was useful but still passive — Claude Code could read my notes but had no way to interact with the infrastructure. I wanted Claude to actually be able to control the homelab: check what VMs are running, install services, run commands, query Prometheus metrics.

MCP (Model Context Protocol) is how Claude Code connects to external tools. Instead of just answering questions about the homelab, Claude can make API calls and run SSH commands against it.

Built a custom MCP server called `homelab-mcp` (v1.6.0) in Python. It runs as a background process and exposes tools that Claude Code can call during a conversation. Installed it in a dedicated virtualenv under `~/arsenal/mcp-servers/`.

What it can do:

* **VM management** — list VMs, check status, start/stop/reboot via Proxmox API
* **SSH execution** — run commands on any registered host without leaving the Claude session
* **Service installation** — deploy new Docker services from templates
* **Network discovery** — scan the network, map devices, detect infrastructure drift
* **Monitoring** — query Prometheus metrics and service health

The practical result: I can ask Claude to check if a container is down, deploy a new service, or run a diagnostic command and it actually does it. The homelab goes from something I SSH into manually to something I can manage through conversation.

---

## VM Resize

Ubuntu Server VM was hitting CPU limits on 2 cores. Resized all three VMs to better use the node's resources:

| VM | Before | After |
|---|---|---|
| Ubuntu Server | 2 cores / 6GB / 80GB | 4 cores / 8GB / 120GB |
| Kali Linux | 2 cores / 4GB / 50GB | 2 cores / 4GB / 60GB |
| Metasploitable | 1 core / 512MB / 16GB | 1 core / 1GB / 20GB |

Used `pvesh` to update CPU and RAM config, `qm resize` for disk, then extended the Ubuntu filesystem inside the guest with `lvextend` and `resize2fs`.

---

## OnlyOffice + Nextcloud Integration

Added OnlyOffice Document Server as a Docker container for editing `.docx`, `.xlsx`, and `.pptx` files directly inside Nextcloud.

The integration required:
* Installing the `onlyoffice` app in Nextcloud via `occ app:install`
* Matching the JWT secret from OnlyOffice's `local.json` config
* Setting the JWT header to `Authorization` (default, not `AuthorizationJwt`)
* Setting `StorageUrl` to `http://[server-ip]:8080/` so OnlyOffice can reach Nextcloud

The tricky part was the JWT header — OnlyOffice was reaching Nextcloud and Nextcloud was returning 403 with "Download empty without jwt" in the logs. The fix was changing the header name from `AuthorizationJwt` to `Authorization`.

---

## DNS Overhaul — systemd-resolved + Split DNS

The original DNS setup locked `/etc/resolv.conf` with `chattr +i` pointing at `8.8.8.8`. It worked for external DNS but broke Tailscale MagicDNS — `.ts.net` hostnames didn't resolve.

Root cause chain:
1. Pi-hole was bound to `0.0.0.0:53`, which claimed `127.0.0.53:53`
2. That blocked systemd-resolved from starting its stub listener
3. Tailscale's DNS proxy forwards general queries to `127.0.0.53` — but nothing was there, causing timeouts
4. MagicDNS queries died silently

Fix:
* Rebind Pi-hole to `[server-ip]:53` only — frees up `127.0.0.53` for systemd-resolved
* Enable systemd-resolved with `8.8.8.8` as fallback
* Re-enable `tailscale set --accept-dns=true` — Tailscale wires itself into systemd-resolved automatically
* Result: `.ts.net` hostnames resolve via `tailscale0`, everything else goes through Pi-hole

Also bound Pi-hole to `[tailscale-ip]:53` (the Tailscale IP) so `.home` domains and ad blocking work on all Tailscale devices from anywhere, not just the local network.

---

## DNS Boot Check Service

The DNS overhaul fixed split DNS, but there was no guarantee the setup would survive a reboot. systemd-resolved needs to be running, `/etc/resolv.conf` needs to point at the stub listener, and Tailscale needs `accept-dns=true` — all before anything else comes up.

Wrote a boot script (`dns-boot-check.sh`) and wired it into systemd as a one-shot service that runs after `network-online.target` and `tailscaled.service`. The script checks that `/etc/resolv.conf` points at the systemd-resolved stub (and fixes it if not), confirms systemd-resolved is active, sets `tailscale set --accept-dns=true`, and tests that both external DNS and MagicDNS are resolving. Everything logged to `/var/log/dns-boot-check.log`.

The fix part matters — if the symlink is wrong at boot, the script corrects it with `chattr -i` and `ln -sf` before anything tries to use DNS.

---

## HTTPS on .home Domains

Generated a single self-signed cert covering all active `.home` domains with a 10-year expiry:

```bash
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -subj "/CN=homelab/O=Jean Homelab" \
  -addext "subjectAltName=DNS:nextcloud.home,DNS:pihole.home,DNS:portainer.home,DNS:grafana.home,DNS:npm.home"
```

Uploaded to NPM as a custom certificate, applied to each proxy host with Force SSL enabled. Installed the cert as a trusted CA on Windows and Android so no browser warnings.

---

## Daily Backups to Proxmox

Set up a daily backup script that runs at 3am via cron. Uses Docker's alpine image to tar each volume, then SCP to Proxmox. Keeps 7 days of history and cleans up automatically.

Volumes backed up: `nextcloud_data`, `pihole_data`, `dnsmasq_data`, `nginx-proxy-manager_npm_data`, `nginx-proxy-manager_npm_letsencrypt`.

Passwordless SSH from ubuntu-server to Proxmox using the existing ed25519 key.

---

## MCP Keyring Auth

The original MCP setup stored the Proxmox password in a plaintext file at `~/.proxmox-pass`. It worked but any process that could read the home directory had the password.

Switched to `keyrings.alt` — a file-based keyring backend for Python. The MCP wrapper script now retrieves the Proxmox password from the keyring at runtime instead of reading a plaintext file. The `.proxmox-pass` file was deleted.

```bash
python3 -c "import keyring; keyring.set_password('proxmox', 'root@pam', 'yourpassword')"
```

The wrapper script reads it with `keyring.get_password('proxmox', 'root@pam')` and passes it to the MCP server at startup. No plaintext credentials anywhere in the filesystem.

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
* How MCP (Model Context Protocol) works and building a custom server that gives Claude Code control over infrastructure
* How reverse proxies work and setting up clean internal domains with NPM and Pi-hole
* Why CGNAT blocks external proxying and how to work around it internally
* How Proxmox auth breaks behind a reverse proxy and the redirect workaround
* How Tailscale Split DNS extends local DNS to remote devices without breaking regular internet
* How systemd-resolved works as a stub listener and why it has to coexist with Pi-hole and Tailscale
* Resizing a VM disk on Proxmox and extending the filesystem inside the guest with lvextend and resize2fs
* Generating a self-signed wildcard cert with openssl and installing it as a trusted CA on Windows and Android
* Automating Docker volume backups with cron, tar inside an alpine container, and SCP to Proxmox
* How OnlyOffice JWT authentication works and why the header name matters for the Nextcloud integration
* How to use systemd one-shot services for boot-time infrastructure checks
* Securing credentials with a file-based keyring instead of plaintext files

---

## What's Next

* ~~MCP server integration with Claude Code~~ — done, homelab-mcp v1.6.0
* ~~Nginx Proxy Manager internally~~ — done, all services on `.home` domains with HTTPS
* ~~Watchtower for automated container updates~~ — done, running
* ~~Metasploitable VM for local pentesting~~ — done, actively exploiting with Kali
* ~~OnlyOffice document editing in Nextcloud~~ — done
* ~~Daily backups to Proxmox~~ — done, 7-day retention
* Document TryHackMe rooms done with the Kali VM
