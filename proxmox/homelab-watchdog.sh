#!/bin/bash
# Homelab watchdog — pings ubuntu VM + checks proxmox root disk, alerts Discord on transitions.
# Runs every minute via root crontab. State files keep alerts edge-triggered (no spam).

# shellcheck disable=SC1091
[ -f /etc/homelab-alerts.env ] && . /etc/homelab-alerts.env

DISCORD="${DISCORD_WEBHOOK_URL}"
STATE_FILE="/var/tmp/homelab_watchdog_state"
DISK_STATE_FILE="/var/tmp/homelab_watchdog_disk_state"
CERT_STATE_FILE="/var/tmp/homelab_watchdog_cert_state"
HOST="192.168.1.79"
DISK_THRESHOLD=85
CERT_THRESHOLD_DAYS=14
CERT_HOST="192.168.1.79"
CERT_SNI="grafana.home"
CERT_PORT=443

alert() {
    [ -z "$DISCORD" ] && return
    curl -s -X POST "$DISCORD" \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"$1\"}" >/dev/null
}

# --- VM check ---
if ping -c1 -W2 "$HOST" > /dev/null 2>&1 && \
   curl -sf --max-time 5 "http://$HOST:3000/api/health" > /dev/null 2>&1; then
    CURRENT="up"
else
    CURRENT="down"
fi

PREVIOUS=$(cat "$STATE_FILE" 2>/dev/null || echo "up")

if [ "$CURRENT" != "$PREVIOUS" ]; then
    echo "$CURRENT" > "$STATE_FILE"
    if [ "$CURRENT" = "down" ]; then
        alert "🔴 **HOMELAB DOWN** — ubuntu VM (192.168.1.79) is unreachable. All services offline."
    else
        alert "🟢 **HOMELAB RESTORED** — ubuntu VM (192.168.1.79) is back online."
    fi
fi

# --- Disk check (Proxmox root) ---
DISK_PCT=$(df / | awk 'NR==2 {print int($5)}')
DISK_PREVIOUS=$(cat "$DISK_STATE_FILE" 2>/dev/null || echo "ok")

if [ "$DISK_PCT" -ge "$DISK_THRESHOLD" ]; then
    DISK_CURRENT="warn"
else
    DISK_CURRENT="ok"
fi

if [ "$DISK_CURRENT" != "$DISK_PREVIOUS" ]; then
    echo "$DISK_CURRENT" > "$DISK_STATE_FILE"
    if [ "$DISK_CURRENT" = "warn" ]; then
        alert "🟡 **PROXMOX DISK WARNING** — root filesystem at ${DISK_PCT}% (threshold: ${DISK_THRESHOLD}%). Check /var/lib/vz/dump."
    else
        alert "✅ **PROXMOX DISK OK** — root filesystem back below ${DISK_THRESHOLD}% (now ${DISK_PCT}%)."
    fi
fi

# --- Cert expiry check (.home cert served by NPM on .79:443) ---
CERT_END=$(echo | openssl s_client -connect "$CERT_HOST:$CERT_PORT" -servername "$CERT_SNI" 2>/dev/null \
    | openssl x509 -noout -enddate 2>/dev/null \
    | cut -d= -f2)

if [ -n "$CERT_END" ]; then
    CERT_END_EPOCH=$(date -d "$CERT_END" +%s 2>/dev/null)
    NOW_EPOCH=$(date +%s)
    if [ -n "$CERT_END_EPOCH" ]; then
        DAYS_LEFT=$(( (CERT_END_EPOCH - NOW_EPOCH) / 86400 ))

        if [ "$DAYS_LEFT" -le "$CERT_THRESHOLD_DAYS" ]; then
            CERT_CURRENT="warn"
        else
            CERT_CURRENT="ok"
        fi

        CERT_PREVIOUS=$(cat "$CERT_STATE_FILE" 2>/dev/null || echo "ok")
        if [ "$CERT_CURRENT" != "$CERT_PREVIOUS" ]; then
            echo "$CERT_CURRENT" > "$CERT_STATE_FILE"
            if [ "$CERT_CURRENT" = "warn" ]; then
                alert "🟡 **CERT EXPIRY WARNING** — homelab cert (${CERT_HOST}:${CERT_PORT}) expires in ${DAYS_LEFT} days (threshold ${CERT_THRESHOLD_DAYS}). Renew + re-upload to NPM."
            else
                alert "✅ **CERT EXPIRY OK** — homelab cert renewed, ${DAYS_LEFT} days left."
            fi
        fi
    fi
fi
