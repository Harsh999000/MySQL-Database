#!/bin/bash
set -euo pipefail

REPO_DIR="/db1/github/mysql"
LOG_DIR="$REPO_DIR/logs"
TODAY=$(date +%F)

cd "$REPO_DIR"

# Force add ignored log files
git add -f logs/*.log 2>/dev/null || true

# Only commit if there are staged changes
if git diff --cached --quiet; then
  echo "No new logs to commit."
  exit 0
fi

git commit -m "MySQL log upload: $TODAY"
git push origin main
