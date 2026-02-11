#!/bin/bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
CRONLOG_DIR="/db1/myserver/mysql/cronlog"
LOG_DATE="$(date +%F)"
CRONLOG_FILE="$CRONLOG_DIR/mysql-cronlog-$LOG_DATE.log"

mkdir -p "$CRONLOG_DIR"

log() {
  {
    echo "--------------------------------------------------"
    echo "[ $(date '+%Y-%m-%d %H:%M:%S') ] [$SCRIPT_NAME]"
    echo "$@"
  } | tee -a "$CRONLOG_FILE"
}

# =====================
# PATHS & RETENTION
# =====================

GITHUB_LOG_DIR="/db1/github/mysql/logs"
MYSQL_LOG_DIR="/db1/myserver/mysql/logs"
CRON_LOG_DIR="/db1/myserver/mysql/cronlog"

GITHUB_RETENTION_DAYS=7
MYSQL_RETENTION_DAYS=14
CRON_RETENTION_DAYS=14

log "Starting MySQL log cleanup"

# =====================
# GITHUB LOG CLEANUP (7 DAYS)
# =====================

if [ -d "$GITHUB_LOG_DIR" ]; then
  log "Deleting GitHub MySQL logs older than $GITHUB_RETENTION_DAYS days"

  find "$GITHUB_LOG_DIR" -type f \
    -regextype posix-extended \
    -regex ".*/(general|error|slow|startup)-[0-9]{4}-[0-9]{2}-[0-9]{2}\.log" \
    -mtime +"$GITHUB_RETENTION_DAYS" \
    -print -delete
else
  log "GitHub log directory not found: $GITHUB_LOG_DIR"
fi

# =====================
# MYSQL ROTATED LOG CLEANUP (14 DAYS)
# =====================

if [ -d "$MYSQL_LOG_DIR" ]; then
  log "Deleting rotated MySQL logs older than $MYSQL_RETENTION_DAYS days"

  find "$MYSQL_LOG_DIR" -type f \
    -regextype posix-extended \
    -regex ".*/(general|error|slow|startup)-[0-9]{4}-[0-9]{2}-[0-9]{2}\.log" \
    -mtime +"$MYSQL_RETENTION_DAYS" \
    -print -delete
else
  log "MySQL log directory not found: $MYSQL_LOG_DIR"
fi

# =====================
# CRON LOG CLEANUP (14 DAYS)
# =====================

if [ -d "$CRON_LOG_DIR" ]; then
  log "Deleting cron logs older than $CRON_RETENTION_DAYS days"

  find "$CRON_LOG_DIR" -type f \
    -regextype posix-extended \
    -regex ".*/mysql-cronlog-[0-9]{4}-[0-9]{2}-[0-9]{2}\.log" \
    -mtime +"$CRON_RETENTION_DAYS" \
    -print -delete
else
  log "Cron log directory not found: $CRON_LOG_DIR"
fi

log "MySQL log cleanup completed"
