#!/bin/bash
[ -f /etc/homelab-alerts.env ] && . /etc/homelab-alerts.env
[ -z "$DISCORD_WEBHOOK_URL" ] && exit 0
[ "$PAM_TYPE" != "open_session" ] && exit 0

HOST=$(hostname)
MSG="🔑 SSH login: ${PAM_USER} from ${PAM_RHOST:-local} on ${HOST}"

curl -fsS -X POST "$DISCORD_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "{\"content\": \"$MSG\"}" >/dev/null 2>&1 || true
exit 0
