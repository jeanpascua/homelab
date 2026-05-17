#!/bin/bash
# fail2ban → Discord webhook bridge. Reads DISCORD_WEBHOOK_URL from
# /etc/homelab-alerts.env. No-op if env missing. Safe in fail2ban action
# context (no stdin, no terminal).
#
# Usage: fail2ban-discord <event> <jail> <ip> [failures]
#   event = BAN | UNBAN | START | STOP

set -e

ENV_FILE="${HOMELAB_ALERTS_ENV:-/etc/homelab-alerts.env}"
[ -f "$ENV_FILE" ] || exit 0

# shellcheck disable=SC1090
. "$ENV_FILE"
[ -n "${DISCORD_WEBHOOK_URL:-}" ] || exit 0

EVENT="${1:-?}"
JAIL="${2:-?}"
IP="${3:-?}"
FAILURES="${4:-?}"
HOST=$(hostname -s)
NOW=$(date '+%Y-%m-%d %H:%M:%S')

case "$EVENT" in
  BAN)   ICON="🔥" ;;
  UNBAN) ICON="⚪" ;;
  START) ICON="✅" ;;
  STOP)  ICON="🔴" ;;
  *)     ICON="❔" ;;
esac

if [ "$EVENT" = "BAN" ]; then
  MSG="${ICON} fail2ban [${JAIL}] **BAN** ${IP} on \`${HOST}\` (failures: ${FAILURES}) — ${NOW}"
elif [ "$EVENT" = "UNBAN" ]; then
  MSG="${ICON} fail2ban [${JAIL}] **UNBAN** ${IP} on \`${HOST}\` — ${NOW}"
else
  MSG="${ICON} fail2ban **${EVENT}** on \`${HOST}\` — ${NOW}"
fi

JSON=$(MSG="$MSG" python3 -c 'import json,os; print(json.dumps({"content":os.environ["MSG"]}))')
curl -fsS -X POST "$DISCORD_WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  --max-time 5 \
  --data "$JSON" >/dev/null 2>&1 || true

exit 0
