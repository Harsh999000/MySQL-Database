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

MYSQL_BIN="/db1/myserver/mysql/mysql_files/mysql/bin/mysql"
MYSQL_SOCKET="/db1/myserver/mysql/run/mysql.sock"

read -p "username: " MYSQL_USER
read -s -p "password: " MYSQL_PASSWORD
echo

log "Attempting MySQL login for user: $MYSQL_USER"

"$MYSQL_BIN" --socket="$MYSQL_SOCKET" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD"
