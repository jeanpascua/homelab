#!/bin/bash
LOG="/var/log/dns-boot-check.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"; }

log "Boot DNS check starting"

# Ensure resolv.conf points to systemd-resolved stub
RESOLV_TARGET="/run/systemd/resolve/stub-resolv.conf"
if [ "$(readlink /etc/resolv.conf)" != "$RESOLV_TARGET" ]; then
    log "WARN: resolv.conf not pointing to systemd-resolved stub — fixing"
    chattr -i /etc/resolv.conf 2>/dev/null
    ln -sf "$RESOLV_TARGET" /etc/resolv.conf
    log "Fix applied"
else
    log "resolv.conf stub symlink OK"
fi

# Ensure systemd-resolved is running
if ! systemctl is-active --quiet systemd-resolved; then
    log "WARN: systemd-resolved not running — starting"
    systemctl start systemd-resolved
fi

# Ensure Tailscale accepts DNS (needed for MagicDNS + split DNS)
if command -v tailscale &>/dev/null; then
    tailscale set --accept-dns=true 2>/dev/null
    log "Tailscale accept-dns=true confirmed"
fi

# Test external DNS
if nslookup api.anthropic.com 127.0.0.53 &>/dev/null; then
    log "External DNS OK — api.anthropic.com resolves"
else
    log "ERROR: api.anthropic.com not resolving"
fi

# Test MagicDNS
if nslookup ubuntu.tailc4b273.ts.net 127.0.0.53 &>/dev/null; then
    log "MagicDNS OK — ubuntu.tailc4b273.ts.net resolves"
else
    log "WARN: MagicDNS not resolving (Tailscale may still be connecting)"
fi

log "Boot DNS check complete"
