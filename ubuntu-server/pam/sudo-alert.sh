#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
[ "$PAM_TYPE" != "open_session" ] && exit 0
WEBHOOK_FILE=/home/jean/.config/cron-alerts/discord-webhook
[ -f "$WEBHOOK_FILE" ] || exit 0
DISCORD_WEBHOOK_URL=$(cat "$WEBHOOK_FILE")
[ -z "$DISCORD_WEBHOOK_URL" ] && exit 0
HOST=$(hostname)
PAYLOAD=$(printf '{"content": "sudo: %s -> root on %s"}' "${PAM_RUSER:-unknown}" "$HOST")
curl -sS -X POST "$DISCORD_WEBHOOK_URL" -H "Content-Type: application/json" -d "$PAYLOAD" >> /tmp/sudo-alert.log 2>&1
exit 0
