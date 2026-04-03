#!/usr/bin/env bash
# Build data/raj_electronics.db from data/clients.csv using sqlite3 CLI.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DB="$ROOT/data/raj_electronics.db"
CSV="$ROOT/data/clients.csv"

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "sqlite3 not found. Install SQLite (macOS: pre-installed; Windows: sqlite.org)."
  exit 1
fi

if [[ ! -f "$CSV" ]]; then
  echo "Missing $CSV"
  exit 1
fi

rm -f "$DB"
sqlite3 "$DB" <"$ROOT/sql/01_schema.sql"
sqlite3 "$DB" <<EOF
.mode csv
.import --skip 1 ${CSV} clients
EOF

echo "Loaded $(sqlite3 "$DB" "SELECT COUNT(*) FROM clients;") rows -> $DB"
