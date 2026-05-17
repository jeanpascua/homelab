#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
[ -f /etc/homelab-alerts.env ] && . /etc/homelab-alerts.env
[ -z "$DISCORD_WEBHOOK_URL" ] && exit 0
[ "$PAM_TYPE" != "open_session" ] && exit 0
HOST=$(hostname)
PAYLOAD=$(printf '{"content": "🔑 **SSH login** — %s from %s on %s"}' "$PAM_USER" "${PAM_RHOST:-local}" "$HOST")
curl -sS -X POST "$DISCORD_WEBHOOK_URL" -H "Content-Type: application/json" -d "$PAYLOAD" >/dev/null 2>&1
exit 0
