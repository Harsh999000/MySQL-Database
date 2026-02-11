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
# MYSQL ADMIN CONFIG
# =====================

MYSQLADMIN="/db1/myserver/mysql/mysql_files/mysql/bin/mysqladmin"
MYSQL_SOCKET="/db1/myserver/mysql/run/mysql.sock"

MYSQL_USER="root"
MYSQL_PASSWORD="password_here"   # TEMPORARY — will move to secrets later

# =====================
# FLUSH LOGS
# =====================

log "Flushing MySQL logs..."

"$MYSQLADMIN" \
  --socket="$MYSQL_SOCKET" \
  -u "$MYSQL_USER" \
  -p"$MYSQL_PASSWORD" \
  flush-logs

log "MySQL log flush completed successfully"
