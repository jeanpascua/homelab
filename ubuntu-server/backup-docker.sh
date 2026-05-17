#!/bin/bash
DEST="root@192.168.1.76:/backups/ubuntu-server"
DATE=$(date +%Y-%m-%d)
LOG="/home/jean/backup.log"
TMPDIR="/home/jean/backup-tmp"
KEEP_DAYS=7
WEBHOOK_FILE="$HOME/.config/cron-alerts/discord-webhook"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"; }

mkdir -p "$TMPDIR"
log "Backup started"

VOLUMES=(
  "nextcloud_data"
  "pihole_data"
  "dnsmasq_data"
  "nginx-proxy-manager_npm_data"
  "nginx-proxy-manager_npm_letsencrypt"
  "jobsync_jobsync_data"
  "monitoring_grafana_data"
  "monitoring_prometheus_data"
  "portainer_data"
  "onlyoffice_data"
  "onlyoffice_logs"
)

ERRORS=()

for VOL in "${VOLUMES[@]}"; do
  log "Backing up $VOL"
  TAR_ERR=$(docker run --rm \
    -v "$VOL":/data:ro \
    -v "$TMPDIR":/backup \
    --user "$(id -u):$(id -g)" \
    alpine tar czf "/backup/${VOL}_${DATE}.tar.gz" -C /data . 2>&1 >/dev/null)
  if [ -n "$TAR_ERR" ]; then
    log "WARN tar stderr for $VOL: $TAR_ERR"
  fi

  SCP_ERR=$(scp "$TMPDIR/${VOL}_${DATE}.tar.gz" "$DEST/${VOL}_${DATE}.tar.gz" 2>&1 >/dev/null)
  if [ $? -eq 0 ] && [ -z "$SCP_ERR" ]; then
    log "$VOL OK"
  else
    log "ERROR: failed to transfer $VOL: $SCP_ERR"
    ERRORS+=("$VOL")
  fi
done

CLEAN_ERR=$(ssh root@192.168.1.76 "find /backups/ubuntu-server -name '*.tar.gz' -mtime +${KEEP_DAYS} -delete" 2>&1)
if [ -n "$CLEAN_ERR" ]; then
  log "WARN cleanup stderr: $CLEAN_ERR"
fi
log "Old backups cleaned up (.76)"

# Sync today's backups to R2
RCLONE_OUT=$(rclone copy "$TMPDIR" r2:homelab-backups 2>&1)
if [ $? -eq 0 ]; then
  log "R2 sync OK"
  rclone delete r2:homelab-backups --min-age $((KEEP_DAYS + 1))d >> "$LOG" 2>&1 || true
else
  log "ERROR: R2 sync failed: $RCLONE_OUT"
  ERRORS+=("r2-sync")
fi

rm -rf "$TMPDIR"
log "Backup complete"

# Discord alert if any failures
if [ ${#ERRORS[@]} -gt 0 ] && [ -f "$WEBHOOK_FILE" ]; then
  WEBHOOK=$(head -c 500 "$WEBHOOK_FILE" | tr -d '\n\r ')
  if [ -n "$WEBHOOK" ]; then
    MSG="🔴 backup-docker ($DATE) failed on ${#ERRORS[@]}/${#VOLUMES[@]} volumes: ${ERRORS[*]}. Log: $LOG"
    ESCAPED=$(printf '%s' "$MSG" | jq -Rs .)
    curl -fsS -X POST "$WEBHOOK" -H 'Content-Type: application/json' \
      --data "{\"content\":$ESCAPED}" >/dev/null 2>&1 || true
  fi
fi
