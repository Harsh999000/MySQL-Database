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

LOG_DIR="/db1/github/mysql/logs"

log "Starting MySQL log sanitization in: $LOG_DIR"

if [ ! -d "$LOG_DIR" ]; then
  log "ERROR: Log directory does not exist"
  exit 1
fi

find "$LOG_DIR" -type f -name "*.log" | while read -r file; do
  log "Sanitizing file: $file"

  sed -i 's/\b[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}\b/xxx.xxx.xxx.xxx/g' "$file"
  sed -i 's/:[0-9]\{2,5\}/:PORT/g' "$file"
  sed -i 's/port=[0-9]\{2,5\}/port=PORT/g' "$file"
  sed -i 's/user=[^ ]\+/user=USER/g' "$file"
  sed -i "s/'[^']*'@'[^']*'/'USER'@'HOST'/g" "$file"
  sed -i 's/password=[^ ]\+/password=*******/g' "$file"
  sed -i 's/using password: YES/using password: ***/g' "$file"
  sed -i 's/using password: NO/using password: ***/g' "$file"
  sed -i 's/[A-Za-z0-9._%+-]\+@[A-Za-z0-9.-]\+\.[A-Za-z]\{2,6\}/EMAIL_REDACTED/g' "$file"
  sed -i 's/\+*[0-9][0-9 \-]\{8,14\}[0-9]/PHONE_REDACTED/g' "$file"
done

log "MySQL log sanitization complete"
