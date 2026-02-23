# MySQL Database Server – Manual Linux Setup

This project documents a manually configured MySQL server running on Debian Linux with deterministic automation and logging lifecycle management.

The system is built as a learning-focused infrastructure project, applying production-style operational discipline on a local server environment.

---

## Overview

This server includes:

- Dedicated MySQL instance (port 3310)
- Manual service control scripts (start / stop / status)
- Master lifecycle orchestration script
- Automated nightly database backup
- Deterministic log rotation (date-based format)
- Log sanitization before archival
- Retention-based log cleanup policy
- Controlled GitHub archival of rotated logs
- Cron-based lifecycle scheduling
- Strict isolation from MariaDB and PostgreSQL instances

Logs from other internal projects are stored and archived here using a structured append-only model.

---

## Nightly Lifecycle Execution

The entire MySQL maintenance workflow is orchestrated by:

`run-mysql-lifecycle.sh`

This script executes all steps sequentially.  
If any step fails, execution stops immediately.

---

## Execution Window

- **MySQL** → 00:00 A.M.
- **MariaDB** → 00:15 A.M.
- **PostgreSQL** → 00:30 A.M.

Database families are staggered to prevent disk I/O contention and ensure predictable resource allocation.

---

## Lifecycle Flow (Sequential)

1. Backup MySQL database
2. Rotate logs to dated format
3. Flush MySQL logs
4. Sanitize logs
5. Apply retention cleanup policy
6. Force-add and push rotated logs to GitHub

All steps execute in strict order.

---

## Log Lifecycle Design

### Active Logs:
- `general.log`
- `error.log`
- `slow.log`

### After Rotation:
- `general-YYYY-MM-DD.log`
- `error-YYYY-MM-DD.log`
- `slow-YYYY-MM-DD.log`

### Retention Policy:

- GitHub logs: append-only archival model
- Local rotated logs: 14-day retention
- Cron logs: 14-day retention

Log files are ignored by default via `.gitignore`.  
They are explicitly force-added during controlled archival.

---

## Isolation Principles

This MySQL instance is fully isolated from other database systems by:

- Dedicated port (3310)
- Dedicated socket file
- Dedicated PID file
- Dedicated data directory
- Dedicated log directory
- PID-file-based process management
- No process-name-based killing (no pgrep collisions)
- Separate lifecycle execution window

---

## Environment

- Debian Linux
- Manual MySQL installation (no systemd dependency)
- Cron-based orchestration
- Local server laptop (non-public environment)

---

## Design Philosophy

- Deterministic execution order
- Sequential orchestration via master lifecycle script
- Resource-window staggering between database families
- Append-only archival strategy in GitHub
- Clear separation between runtime directory (`/db1/myserver/mysql`) and source-controlled directory (`/db1/github/mysql`)
- Infrastructure built for learning with production-grade discipline

---

## Purpose

This repository serves as:

- A hands-on infrastructure engineering project
- A structured MySQL server implementation reference
- A demonstration of database lifecycle automation
- A foundation for future hardening (secrets management, monitoring, alerting, remote exposure controls)
