#!/usr/bin/env bash
# Load anonymized CSV into PostgreSQL. Set PG* env vars or defaults below.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CSV="$ROOT/data/clients.csv"

: "${PGDATABASE:=raj_electronics}"
: "${PGHOST:=localhost}"
: "${PGPORT:=5432}"
: "${PGUSER:=$USER}"

export PGDATABASE PGHOST PGPORT PGUSER

if [[ ! -f "$CSV" ]]; then
  echo "Missing $CSV"
  exit 1
fi

if ! command -v psql >/dev/null 2>&1; then
  echo "psql not found. Install PostgreSQL client."
  exit 1
fi

psql -v ON_ERROR_STOP=1 -f "$ROOT/postgres/schema.sql"
psql -v ON_ERROR_STOP=1 -c "\\copy clients FROM '${CSV}' WITH (FORMAT csv, HEADER true)"

echo "Loaded into database: $PGDATABASE (user=$PGUSER host=$PGHOST)"
