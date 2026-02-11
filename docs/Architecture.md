# MySQL Server Architecture

This document describes the automated operational lifecycle of the MySQL server instance running on the server laptop.

The system is designed for deterministic daily execution and clean separation of responsibilities.

---

## Daily Automation Schedule

All operations are executed sequentially starting at 12:01 A.M.

---

### 12:01 A.M – Backup MySQL Database

Script: `backup-mysql.sh`

**Purpose:**
- Creates a full backup of MySQL database data.
- Ensures recoverability in case of corruption or failure.
- Backup is stored in designated backup directory.

This step protects database data before any log manipulation begins.

---

### 12:02 A.M – Rotate Logs

Script: `rotate-logs-mysql.sh`

**Purpose:**
- Renames active logs to dated format:
  - `general-YYYY-MM-DD.log`
  - `error-YYYY-MM-DD.log`
  - `slow-YYYY-MM-DD.log`
  - `startup-YYYY-MM-DD.log`
- Creates fresh empty log files for:
  - `general.log`
  - `error.log`
  - `slow.log`
- Copies rotated logs to GitHub logs directory for archival.

This ensures:
- Daily log separation
- Clean lifecycle management
- Compatibility with retention policy

---

### 12:03 A.M – Flush Logs

Script: `flush-logs-mysql.sh`

**Purpose:**
- Forces MySQL to close and reopen log file descriptors.
- Ensures MySQL writes to newly created log files.
- Prevents continued writing to rotated files.

This guarantees correct log rotation behavior.

---

### 12:04 A.M – Sanitize Logs

Script: `sanitize-logs-mysql.sh`

**Purpose:**
- Removes sensitive or unnecessary information from logs.
- Cleans entries before archival.
- Ensures logs are safe for long-term storage and version control.

This step protects sensitive data before pushing to GitHub.

---

### 12:05 A.M – Delete Logs (Retention Policy)

Script: `delete-logs-mysql.sh`

**Retention Rules:**

- GitHub logs directory:
  - Delete logs older than 7 days (local copy only).
- Internal MySQL rotated logs:
  - Delete logs older than 14 days.
- Cron execution logs:
  - Delete logs older than 14 days.

Active logs (`general.log`, `error.log`, `slow.log`) are never deleted.

This enforces controlled storage usage.

---

### 12:06 A.M – Auto Push Logs to GitHub

Script: `auto-push-logs-mysql.sh`

**Purpose:**
- Force-adds rotated log files (ignored by default via `.gitignore`).
- Commits new logs only.
- Does not stage deletions.
- Pushes updates to remote GitHub repository.

Important:
- Deleted local logs do NOT get deleted from GitHub.
- GitHub acts as append-only archive.

---

## Isolation Principles

This MySQL instance is fully isolated from MariaDB instance by:

- Dedicated port (3310)
- Dedicated socket file
- Dedicated PID file
- Dedicated data directory
- Dedicated log directory
- PID-file-based process management (no pgrep usage)

This prevents cross-instance interference.

---

## Design Philosophy

- Deterministic execution order
- Strict process isolation
- Clear log lifecycle
- Retention policy enforcement
- Append-only archival strategy in GitHub
- Safe automation via cron scheduling
