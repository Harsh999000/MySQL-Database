#!/bin/bash
set -euo pipefail

# ==================================================
# MySQL Nightly Lifecycle Orchestrator
# Executes all maintenance steps sequentially.
# If any step fails, execution stops immediately.
# ==================================================

SCRIPT_NAME="$(basename "$0")"
CRONLOG_DIR="/db1/myserver/mysql/cronlog"
LOG_DATE="$(date +%F)"
CRONLOG_FILE="$CRONLOG_DIR/mysql-cronlog-$LOG_DATE.log"

mkdir -p "$CRONLOG_DIR"

log() {
  {
    echo "=================================================="
    echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] [$SCRIPT_NAME]"
    echo "$@"
  } | tee -a "$CRONLOG_FILE"
}

BASE="/db1/myserver/mysql/scripts"

log "Starting MySQL full lifecycle"

# --------------------------------------------------
# Backup Database
# Ensures data safety before any log manipulation.
# --------------------------------------------------
"$BASE/backup-mysql.sh" &&
log "Backup completed"

# --------------------------------------------------
# Rotate Logs
# Renames active logs to dated format and creates new ones.
# --------------------------------------------------
"$BASE/rotate-logs-mysql.sh" &&
log "Log rotation completed"

# --------------------------------------------------
# Flush Logs
# Forces MySQL to reopen log file descriptors.
# --------------------------------------------------
"$BASE/flush-logs-mysql.sh" &&
log "Log flush completed"

# --------------------------------------------------
# Sanitize Logs
# Cleans logs before archival.
# --------------------------------------------------
"$BASE/sanitize-logs-mysql.sh" &&
log "Log sanitization completed"

# --------------------------------------------------
# Delete Old Logs
# Applies retention policy.
# --------------------------------------------------
"$BASE/delete-logs-mysql.sh" &&
log "Log cleanup completed"

# --------------------------------------------------
# Auto Push Logs
# Force-adds rotated logs and pushes to GitHub.
# --------------------------------------------------
"$BASE/auto-push-logs-mysql.sh" &&
log "Log push completed"

log "MySQL lifecycle completed successfully"
