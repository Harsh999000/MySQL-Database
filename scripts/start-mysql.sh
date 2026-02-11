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

BASE="/db1/myserver/mysql"
MYSQLD="$BASE/mysql_files/mysql/bin/mysqld"
CONF="$BASE/config/mysql.cnf"
RUN="$BASE/run"
PIDFILE="$RUN/mysql.pid"
LOG="$BASE/logs/error.log"

mkdir -p "$RUN"

# Handle stale PID file
if [ -f "$PIDFILE" ]; then
  PID="$(cat "$PIDFILE")"
  if kill -0 "$PID" 2>/dev/null; then
    log "MySQL already running (PID $PID)"
    exit 0
  else
    log "Stale PID file found. Removing."
    rm -f "$PIDFILE"
  fi
fi

log "Starting MySQL in background..."

"$MYSQLD" --defaults-file="$CONF" --daemonize

sleep 2

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  log "MySQL started successfully (PID $(cat "$PIDFILE"))"
else
  log "MySQL failed to start."
  log "Check error log: $LOG"
  exit 1
fi
