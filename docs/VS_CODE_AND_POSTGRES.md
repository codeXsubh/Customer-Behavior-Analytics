# VS Code + PostgreSQL (how to try both projects)

## Project 1 — Customer Behavioral Analytics (VS Code)

1. **Open the folder**  
   File → Open Folder → select `proj` (the repo root that contains `src/`, `sql/`, `data/`).

2. **Terminal in VS Code**  
   `` Ctrl+` `` (or View → Terminal) → run:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   python src/run_analysis.py
   ```
   Charts and CSVs appear under `outputs/`.

3. **SQL in VS Code**  
   - **Option A (easiest):** Open `sql/02_cohort_retention.sql` as reference; execution is wired through `run_analysis.py` (SQLite in memory).  
   - **Option B (PostgreSQL):** Load CSVs into Postgres (see below), then run the **Postgres** versions under `sql/postgres/`.

**Useful extensions:** Python (Microsoft), optional **SQLTools** + **SQLTools PostgreSQL** if you connect to a local Postgres DB.

---

## PostgreSQL — Project 2 (Raj Electronics)

### Install Postgres (pick one)

- **macOS (Homebrew):** `brew install postgresql@16`, then `brew services start postgresql@16`
- **Docker:**  
  `docker run --name pg -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16`

### Create DB and load (from `raj-electronics-sql/`)

```bash
cd raj-electronics-sql
createdb raj_electronics   # or: psql -U postgres -c "CREATE DATABASE raj_electronics;"
psql -d raj_electronics -f postgres/schema.sql
psql -d raj_electronics -c "\\copy clients FROM '$(pwd)/data/clients.csv' WITH (FORMAT csv, HEADER true)"
```

### Run a report

```bash
psql -d raj_electronics -f postgres/02_kpis.sql
```

Or open **`postgres/`** SQL files in VS Code and run them against `raj_electronics` using **SQLTools** (play button on the query).

### SQLTools (VS Code) — quick setup

1. Install extensions: **SQLTools** and **SQLTools PostgreSQL/Cockroach Driver**.
2. Add a connection: PostgreSQL, host `localhost`, port `5432`, database `raj_electronics`, user/password you configured.
3. New SQL file → connect → run `postgres/02_kpis.sql`.

---

## PostgreSQL — Project 1 (optional)

After you create tables and `COPY` `data/customers.csv` and `data/payments.csv` (see `sql/postgres/00_setup.sql`), run:

- `sql/postgres/02_cohort_retention.sql`
- `sql/postgres/03_payment_recency_delinquency.sql`

`run_analysis.py` still uses **SQLite** by default; Postgres files are for **learning / SQL editor** practice.

---

## Summary

| Project | In VS Code | Database |
|--------|------------|----------|
| **1** | Open `proj`, Terminal → Python | SQLite via script; **optional** Postgres + `sql/postgres/*.sql` |
| **2** | Open `raj-electronics-sql`, SQLTools | **PostgreSQL** (`postgres/schema.sql` + `COPY`) |

SQLite scripts under `raj-electronics-sql/sql/` stay as the **zero-install** path; `postgres/` is for **Postgres / interview-style** environments.
