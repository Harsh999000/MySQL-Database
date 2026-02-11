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
RUN="$BASE/run"
PIDFILE="$RUN/mysql.pid"
SOCKET="$RUN/mysql.sock"

log "Checking MySQL status..."

if [ ! -f "$PIDFILE" ]; then
  log "MySQL is NOT running (PID file missing)"
  exit 1
fi

PID="$(cat "$PIDFILE")"

if ! kill -0 "$PID" 2>/dev/null; then
  log "MySQL is NOT running (stale PID file: $PID)"
  exit 1
fi

log "MySQL process running (PID $PID)"

if [ -S "$SOCKET" ]; then
  log "MySQL socket exists: $SOCKET"
  log "MySQL status: RUNNING"
  exit 0
else
  log "MySQL running but socket missing"
  log "Check error log for startup issues"
  exit 2
fi
