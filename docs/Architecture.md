# MySQL Server Architecture

This document describes the automated operational lifecycle and runtime configuration of the MySQL server instance running on the server laptop.

The system is designed for deterministic daily execution, strict isolation from other database systems, and controlled lifecycle orchestration via a master script.

---

# Runtime Configuration Overview

The MySQL instance is manually configured via a custom `mysqld` configuration file.

## Identity & Paths

- User: `harsh`
- Port: `3310`
- Base Directory: `/db1/myserver/mysql/mysql_files/mysql`
- Data Directory: `/db1/myserver/mysql/data`
- Temporary Directory: `/db1/myserver/mysql/tmp`
- Socket File: `/db1/myserver/mysql/run/mysql.sock`
- PID File: `/db1/myserver/mysql/run/mysql.pid`

The instance runs independently of system-wide MySQL services.

---

## Time Zone Configuration

- Default time zone: `+05:30`

This ensures consistent timestamp alignment with system operations and log rotation scheduling.

---

## Logging Configuration

Logging is intentionally verbose for learning and observability purposes.

### Error Log
- File: `/db1/myserver/mysql/logs/error.log`
- Includes startup and shutdown events.

### General Query Log (Enabled)
- `general_log = ON`
- File: `/db1/myserver/mysql/logs/general.log`
- Logs every connection and every statement.

This is intentionally enabled for transparency and lifecycle testing.

### Slow Query Log
- `slow_query_log = ON`
- File: `/db1/myserver/mysql/logs/slow.log`
- `long_query_time = 1`

Queries exceeding one second are logged.

---

## Character Set Configuration

- `character-set-server = utf8mb4`
- `collation-server = utf8mb4_unicode_ci`

Ensures modern Unicode compatibility.

---

## Safety & Stability Controls

- `skip-symbolic-links`

Prevents unsafe symbolic link usage.

---

## Resource Limitation Strategy

To preserve memory on the server laptop:

- `max_connections = 30`
- `performance_schema = OFF`
- `innodb_log_buffer_size = 16M`

The instance is intentionally tuned for lightweight operation rather than high concurrency.

---

# Execution Model

All maintenance operations are executed by a single master orchestration script:

`run-mysql-lifecycle.sh`

This script runs once daily and executes all maintenance steps sequentially.  
If any step fails, execution stops immediately.

---

# Scheduled Execution Windows

- **MySQL** → 00:00 A.M.
- **MariaDB** → 00:15 A.M.
- **PostgreSQL** → 00:30 A.M.

Database families are staggered to prevent disk I/O contention and memory pressure overlap.

---

# Nightly Lifecycle Flow (Sequential Execution)

The following steps are executed in strict order:

1. Backup MySQL Database  
2. Rotate Logs  
3. Flush Logs  
4. Sanitize Logs  
5. Delete Logs (Retention Policy)  
6. Auto Push Logs to GitHub  

Each step must complete successfully before the next begins.

---

# Step Details

## Backup MySQL Database

Script: `backup-mysql.sh`

Creates a full backup of MySQL database data before any log manipulation occurs.

---

## Rotate Logs

Script: `rotate-logs-mysql.sh`

- Renames active logs to dated format:
  - `general-YYYY-MM-DD.log`
  - `error-YYYY-MM-DD.log`
  - `slow-YYYY-MM-DD.log`
- Creates fresh active log files.
- Copies rotated logs to GitHub logs directory.

---

## Flush Logs

Script: `flush-logs-mysql.sh`

Forces MySQL to reopen log file descriptors to ensure proper rotation behavior.

---

## Sanitize Logs

Script: `sanitize-logs-mysql.sh`

Removes sensitive information before archival.

---

## Delete Logs (Retention Policy)

Script: `delete-logs-mysql.sh`

Retention Rules:

- GitHub logs: delete locally after 7 days.
- Internal rotated logs: delete after 14 days.
- Cron logs: delete after 14 days.
- Active logs are never deleted.

---

## Auto Push Logs to GitHub

Script: `auto-push-logs-mysql.sh`

- Force-adds rotated log files.
- Fetches and rebases before commit.
- Commits only new logs.
- Pushes safely to `main`.

GitHub functions as an append-only archival system.

---

# Log Lifecycle Model

Active Logs:
- `general.log`
- `error.log`
- `slow.log`

Rotated Logs:
- `general-YYYY-MM-DD.log`
- `error-YYYY-MM-DD.log`
- `slow-YYYY-MM-DD.log`

Logs are rotated daily, retained locally under policy, and archived append-only to GitHub.

---

# Isolation Principles

This MySQL instance is fully isolated from MariaDB and PostgreSQL by:

- Dedicated port (3310)
- Dedicated socket file
- Dedicated PID file
- Dedicated data directory
- Dedicated log directory
- PID-file-based process management
- Separate lifecycle execution window

No shared processes, no pgrep-based termination.

---

# Design Philosophy

- Deterministic sequential execution
- Explicit lifecycle orchestration
- Lightweight memory footprint
- Append-only log archival
- Clear separation between runtime (`/db1/myserver/mysql`) and Git-controlled repository (`/db1/github/mysql`)
- Infrastructure built for learning with production-style discipline
