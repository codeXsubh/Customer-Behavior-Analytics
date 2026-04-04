# Raj Electronics — SQL analytics (anonymized)

**SQL-only** reporting on wholesale-style **accounts receivable**: sales, collections, and **outstanding due** by team and region. The numbers come from a real operational spreadsheet; **names and locations are removed** so this repo is safe to publish.

## What this is (30-second version)

A small **SQLite** database (`data/clients.csv` → `clients` table) plus **saved `.sql` reports** you would otherwise build with Excel pivots/sums: KPIs, team rollups, top balances, regional exposure, and simple **due-amount buckets**.

## Cleaning (what was done before Git)

Source: **RAW DATA** sheet (one row per client).

| Step | Why |
| --- | --- |
| **Dropped PII** | Replaced client names and addresses with `client_id` and `region_code` (region = anonymized location bucket). |
| **Stable team keys** | Replaced salesperson names with `team_code` (`T01`…`T08`). |
| **Column names** | Lowercase `snake_case` for SQL. |
| **Dates** | `last_sale_date` as `YYYY-MM-DD` text (SQLite-friendly). |
| **Integrity check** | Enforced `due = total_sale - total_payment` (same as your sheet). |

**Row count:** 200 clients.

## How to run (no Python required)

Needs **`sqlite3`** on your PATH (macOS includes it).

```bash
cd raj-electronics-sql
chmod +x scripts/*.sh   # once
./scripts/load_sqlite.sh    # creates data/raj_electronics.db
./scripts/run_all_sql.sh    # prints all reports
```

Run a single file:

```bash
sqlite3 -header -column data/raj_electronics.db < sql/03_team_summary.sql
```

### PostgreSQL (optional — VS Code / SQLTools / interview practice)

```bash
createdb raj_electronics
cd raj-electronics-sql
chmod +x scripts/*.sh
./scripts/load_postgres.sh   # uses PGUSER/PGHOST/PGPORT/PGDATABASE (see script)
psql -d raj_electronics -f postgres/02_kpis.sql
```

Reports live under `postgres/` (same logic as `sql/`, tuned for PostgreSQL). Full VS Code + Postgres steps: **`../docs/VS_CODE_AND_POSTGRES.md`**.

## Files

| Path | Purpose |
| --- | --- |
| `data/clients.csv` | Clean, anonymized fact table |
| `sql/01_schema.sql` | Table + checks (SQLite) |
| `sql/02_kpis.sql` … `07_*.sql` | Reports (SQLite) |
| `postgres/schema.sql`, `postgres/02_*.sql` … | Same reports for **PostgreSQL** |
| `scripts/load_sqlite.sh` | CSV → SQLite |
| `scripts/run_all_sql.sh` | Run all reports |

## Interview: “What the hell is this?”

**Short answer:**  
“It’s **accounts receivable analytics** for a B2B distributor: each row is a client, with **total sale**, **total payment**, and **due** (balance outstanding). I used to do this in Excel; this repo is the same **business logic** rewritten as **SQL** so it’s versioned, testable, and scalable.”

**If they push on “why SQL?”:**  
“Excel is great for one-off analysis, but SQL is what teams use when data grows, when you need **repeatable** reports, or when multiple people need the **same definitions** of totals and filters. I wanted to show I can translate **real operations** into **queries**.”

**If they ask where the idea came from:**  
“I already maintained this report in Excel for **Raj Electronics** (sales teams, collections, who owes the most). The **idea** is standard in finance/ops: **DSO-style** thinking, **who to chase**, **which team carries the most receivable risk**. I anonymized the data for public GitHub.”

**If they ask “is this real data?”:**  
“The **structure and amounts** are from a real workflow; **identifiers are anonymized** for privacy. In an interview I’d offer to walk through the **schema** and **metric definitions**, not the raw business names.”

## Honest scope (fresher-friendly)

- **Strength:** Clear **GROUP BY**, **KPI math**, **ranking**, **CASE** buckets — typical interview SQL.
- **Stretch next:** Month-over-month trends (needs **transaction-level** or **month columns**), credit risk rules from your richer DATA sheet, automated tests on query results.

---

*Anonymized dataset for portfolio use. Not financial advice.*
