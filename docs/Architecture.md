# MySQL Server Architecture

This document describes the automated operational lifecycle of the MySQL server instance running on the server laptop.

The system is designed for deterministic daily execution, strict isolation from other database systems, and controlled lifecycle orchestration via a master script.

---

## Execution Model

All maintenance operations are executed by a single master orchestration script:

`run-mysql-lifecycle.sh`

This script runs once daily and executes all maintenance steps sequentially.  
If any step fails, execution stops immediately.

MySQL lifecycle execution time:

00:00 A.M.

Other database systems (MariaDB and PostgreSQL) are staggered to prevent disk I/O contention.

---

## Nightly Lifecycle Flow (Sequential Execution)

The following steps are executed in strict order:

1. Backup MySQL Database  
2. Rotate Logs  
3. Flush Logs  
4. Sanitize Logs  
5. Delete Logs (Retention Policy)  
6. Auto Push Logs to GitHub  

Each step must complete successfully before the next begins.

---

## Step Details

### Backup MySQL Database

Script: `backup-mysql.sh`

**Purpose:**
- Creates a full backup of MySQL database data.
- Ensures recoverability in case of corruption or failure.
- Backup is stored in a designated backup directory.

This step protects database data before any log manipulation begins.

---

### Rotate Logs

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
- Copies rotated logs to GitHub logs directory.

This ensures:
- Daily log separation
- Predictable log lifecycle
- Compatibility with retention rules
- Clean archival boundaries

---

### Flush Logs

Script: `flush-logs-mysql.sh`

**Purpose:**
- Forces MySQL to close and reopen log file descriptors.
- Ensures MySQL writes to newly created log files.
- Prevents continued writing to rotated files.

This guarantees correct log rotation behavior.

---

### Sanitize Logs

Script: `sanitize-logs-mysql.sh`

**Purpose:**
- Removes sensitive or unnecessary information from logs.
- Cleans entries before archival.
- Ensures logs are safe for version control and long-term storage.

This step protects sensitive data before GitHub archival.

---

### Delete Logs (Retention Policy)

Script: `delete-logs-mysql.sh`

**Retention Rules:**

- GitHub logs directory:
  - Rotated logs older than 7 days are deleted locally.
- Internal MySQL rotated logs:
  - Deleted after 14 days.
- Cron execution logs:
  - Deleted after 14 days.

Active logs (`general.log`, `error.log`, `slow.log`) are never deleted.

This enforces controlled disk usage while preserving archival integrity.

---

### Auto Push Logs to GitHub

Script: `auto-push-logs-mysql.sh`

**Purpose:**
- Force-adds rotated log files (ignored by default via `.gitignore`).
- Commits only new log files.
- Does not stage deletions.
- Pushes updates to remote GitHub repository.

Important:

- Deleted local logs do NOT get deleted from GitHub.
- GitHub functions as an append-only archive.
- Runtime logs remain ignored unless explicitly added.

---

## Log Lifecycle Model

Active Logs:
- `general.log`
- `error.log`
- `slow.log`

Rotated Logs:
- `general-YYYY-MM-DD.log`
- `error-YYYY-MM-DD.log`
- `slow-YYYY-MM-DD.log`
- `startup-YYYY-MM-DD.log`

Logs are:

- Rotated daily
- Retained locally for controlled duration
- Archived append-only to GitHub

---

## Isolation Principles

This MySQL instance is fully isolated from MariaDB and PostgreSQL instances by:

- Dedicated port (3310)
- Dedicated socket file
- Dedicated PID file
- Dedicated data directory
- Dedicated log directory
- PID-file-based process management
- No process-name-based termination (no pgrep collisions)
- Separate lifecycle execution window

This prevents cross-instance interference and ensures safe coexistence.

---

## Design Philosophy

- Deterministic sequential execution
- Single orchestration entry point
- Strict process isolation
- Explicit log lifecycle management
- Controlled retention enforcement
- Append-only archival strategy in GitHub
- Clear separation between runtime server directory and Git-controlled repository

The architecture is intentionally designed to simulate production-grade operational discipline in a local learning environment.
