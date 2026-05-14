#!/usr/bin/env bash
# sync-secrets.sh — pull homelab secrets from Bitwarden vault → on-disk
# config files. Designed to be:
#  - idempotent (safe to re-run)
#  - additive (preserves other keys in env files)
#  - safe (backs up before overwrite, .bak.<epoch>)
#  - fail-fast (exits non-zero on any missing vault item)
#
# Usage:
#   bw login                         # one-time per machine
#   export BW_SESSION=$(bw unlock --raw)
#   ./sync-secrets.sh
#
# Vault item naming convention:
#   - For raw-secret files (one value per file): item name = file purpose,
#     password field = the secret. Example: "discord-webhook-homelab".
#   - For env files (KEY=value): item name = secret purpose, password
#     field = the value. The KEY is hardcoded below per file.

set -eo pipefail

if [ -z "${BW_SESSION:-}" ]; then
  echo "ERROR: BW_SESSION not set." >&2
  echo "Run: export BW_SESSION=\$(bw unlock --raw)" >&2
  exit 2
fi

# Verify bw responds.
if ! bw status --session "$BW_SESSION" 2>/dev/null | grep -q '"status":"unlocked"'; then
  echo "ERROR: vault not unlocked. Re-run: export BW_SESSION=\$(bw unlock --raw)" >&2
  exit 2
fi

MISSING=()

# Extract the secret value from a vault item — works for both login items
# (password field) and secure notes (notes field). Returns first non-empty.
fetch_secret() {
  local item="$1"
  bw get item "$item" --session "$BW_SESSION" 2>/dev/null \
    | python3 -c "import json,sys
try:
  d=json.load(sys.stdin)
  pw=(d.get('login') or {}).get('password') or ''
  nt=d.get('notes') or ''
  print(pw.strip() or nt.strip())
except Exception:
  pass"
}

# Pull a password field; write entire file = that value (raw secret file).
sync_raw_file() {
  local item="$1" dest="$2" mode="${3:-600}"
  local val
  val=$(fetch_secret "$item")
  if [ -z "$val" ]; then
    MISSING+=("$item → $dest")
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  [ -f "$dest" ] && cp -p "$dest" "$dest.bak.$(date +%s)"
  printf '%s' "$val" > "$dest"
  chmod "$mode" "$dest"
  echo "OK  $dest  (vault: $item)"
}

# In-place upsert KEY=value in an env file; preserve other keys.
sync_env_key() {
  local item="$1" dest="$2" key="$3" mode="${4:-600}"
  local val
  val=$(fetch_secret "$item")
  if [ -z "$val" ]; then
    MISSING+=("$item → $dest [$key]")
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  [ -f "$dest" ] || { touch "$dest"; chmod "$mode" "$dest"; }
  cp -p "$dest" "$dest.bak.$(date +%s)"
  if grep -qE "^${key}=" "$dest"; then
    # sed delim | avoids issues with / in webhook URLs
    sed -i "s|^${key}=.*|${key}=${val}|" "$dest"
  else
    echo "${key}=${val}" >> "$dest"
  fi
  chmod "$mode" "$dest"
  echo "OK  $dest  ($key from vault: $item)"
}

echo "== sync-secrets ($(date +%FT%T)) =="

# Homelab webhook → multiple destinations (mirror for cron + fail2ban use)
sync_raw_file "discord-webhook-homelab" "$HOME/.config/cron-alerts/discord-webhook" 600

# Trading webhook → ~/trading/.env, only the webhook key (preserve other env)
sync_env_key  "discord-webhook-trading" "$HOME/trading/.env" "DISCORD_WEBHOOK_URL" 600

# Job aggregator webhook → ~/scripts/job-aggregator/.env (different key name)
sync_env_key  "discord-webhook-job-aggregator" "$HOME/scripts/job-aggregator/.env" "DISCORD_WEBHOOK_URL" 600

echo ""
if [ ${#MISSING[@]} -gt 0 ]; then
  echo "MISSING (${#MISSING[@]} item(s) not in vault — add via Bitwarden then re-run):"
  for m in "${MISSING[@]}"; do echo "  - $m"; done
  exit 1
fi

echo "All secrets synced from vault."
echo ""
echo "Note: /etc/homelab-alerts.env (root 600) is sync'd separately by a root variant."
echo "      Run: sudo BW_SESSION=\$BW_SESSION /path/to/sync-secrets-root.sh"
exit 0
