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

log "Stopping MySQL..."

if [ ! -f "$PIDFILE" ]; then
  log "MySQL is not running (PID file not found)"
  exit 0
fi

PID="$(cat "$PIDFILE")"

if ! kill -0 "$PID" 2>/dev/null; then
  log "MySQL not running (stale PID file)"
  rm -f "$PIDFILE"
  exit 0
fi

kill -TERM "$PID"

for i in {1..10}; do
  if kill -0 "$PID" 2>/dev/null; then
    sleep 1
  else
    log "MySQL stopped successfully."
    rm -f "$PIDFILE"
    exit 0
  fi
done

log "MySQL did not stop within expected time."
log "Check error log: $BASE/logs/error.log"
exit 1
