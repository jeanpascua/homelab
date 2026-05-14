#!/usr/bin/env bash
# sync-secrets-root.sh — fetches homelab webhook (as user) and installs it to
# /etc/homelab-alerts.env on .79 + .76. Uses sudo only for the final install.
# bw CLI runs as the invoking user so it can read your unlocked vault.
#
# Usage (NOT prefixed with sudo):
#   export BW_SESSION=$(bw unlock --raw)
#   ./sync-secrets-root.sh
#
# Prompts once for sudo password during /etc/ install.

set -euo pipefail

PROXMOX_HOST="${PROXMOX_HOST:-root@192.168.1.76}"

[ -z "${BW_SESSION:-}" ] && { echo "ERROR: BW_SESSION not set. Run: export BW_SESSION=\$(bw unlock --raw)"; exit 2; }

if ! bw status --session "$BW_SESSION" 2>/dev/null | grep -q '"status":"unlocked"'; then
  echo "ERROR: vault locked or session invalid"; exit 2
fi

# Fetch as current user
WEBHOOK=$(bw get item discord-webhook-homelab --session "$BW_SESSION" 2>/dev/null \
  | python3 -c "import json,sys
d=json.load(sys.stdin)
pw=(d.get('login') or {}).get('password') or ''
nt=d.get('notes') or ''
print((pw or nt).strip())")

[ -z "$WEBHOOK" ] && { echo "ERROR: discord-webhook-homelab missing or empty"; exit 4; }

# Write to user-owned temp file first (no secret to /tmp world-readable).
TMP=$(mktemp -p "$HOME")
chmod 600 "$TMP"
echo "DISCORD_WEBHOOK_URL=$WEBHOOK" > "$TMP"

# Install on .79 (local) via sudo
sudo install -m 600 -o root -g root "$TMP" /etc/homelab-alerts.env
echo "OK  /etc/homelab-alerts.env  (local .79)"

# Install on .76 (proxmox) — scp uses root@.76 ssh key, no sudo needed locally
scp -q "$TMP" "$PROXMOX_HOST:/etc/homelab-alerts.env"
ssh "$PROXMOX_HOST" "chmod 600 /etc/homelab-alerts.env && chown root:root /etc/homelab-alerts.env"
echo "OK  /etc/homelab-alerts.env  (on $PROXMOX_HOST)"

rm -f "$TMP"
