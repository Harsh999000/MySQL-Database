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

DATE=$(date +"%Y-%m-%d")

MYSQL_BIN="/db1/myserver/mysql/mysql_files/mysql/bin/mysqldump"
MYSQL_SOCKET="/db1/myserver/mysql/run/mysql.sock"

BACKUP_DIR="/db1/backup/mysql"
BACKUP_FILE="$BACKUP_DIR/all-databases-$DATE.sql"

MYSQL_USER="root"
MYSQL_PASSWORD="password_here"

mkdir -p "$BACKUP_DIR"

log "Starting MySQL daily backup"
log "Target file: $BACKUP_FILE"

"$MYSQL_BIN" \
  --socket="$MYSQL_SOCKET" \
  -u "$MYSQL_USER" \
  -p"$MYSQL_PASSWORD" \
  --all-databases \
  --single-transaction \
  --routines \
  --events \
  --triggers \
  > "$BACKUP_FILE"

log "MySQL daily backup completed successfully"
