#!/bin/bash
# Proxmox vzdump phase hook — Discord alerts on backup result.
# Invoked by vzdump with $1=phase. Env: VMID, DUMPDIR, TARGET, TARFILE, LOGFILE, HOSTNAME.
# Registered via `script: /usr/local/bin/vzdump-hook.sh` in /etc/vzdump.conf.

# shellcheck disable=SC1091
[ -f /etc/homelab-alerts.env ] && . /etc/homelab-alerts.env

DISCORD="${DISCORD_WEBHOOK_URL}"
PHASE="$1"

alert() {
    [ -z "$DISCORD" ] && return
    curl -s -X POST "$DISCORD" \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"$1\"}" >/dev/null
}

case "$PHASE" in
    backup-end)
        SIZE="unknown"
        if [ -n "$TARFILE" ] && [ -f "$TARFILE" ]; then
            SIZE=$(du -h "$TARFILE" 2>/dev/null | awk '{print $1}')
        fi
        alert "✅ **Proxmox backup OK** — VM ${VMID} on ${HOSTNAME}, size ${SIZE}."
        ;;
    backup-abort)
        alert "🔴 **Proxmox backup FAILED** — VM ${VMID} on ${HOSTNAME}. Check ${LOGFILE}."
        ;;
    job-abort)
        alert "🔴 **Proxmox backup JOB aborted** on ${HOSTNAME}. Check pvescheduler logs."
        ;;
esac

exit 0
