#!/usr/bin/env bash
# Load DB (if missing) and print each report with a header.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DB="$ROOT/data/raj_electronics.db"

if [[ ! -f "$DB" ]]; then
  "$ROOT/scripts/load_sqlite.sh"
fi

run() {
  local name=$1
  local file=$2
  echo "========== ${name} =========="
  sqlite3 -header -column "$DB" <"$file"
  echo
}

run "KPIs" "$ROOT/sql/02_kpis.sql"
run "Team summary" "$ROOT/sql/03_team_summary.sql"
run "Top 20 dues" "$ROOT/sql/04_top_dues.sql"
run "Region summary" "$ROOT/sql/05_region_summary.sql"
run "Risk buckets" "$ROOT/sql/06_risk_buckets.sql"
run "Collection pressure by team" "$ROOT/sql/07_collection_pressure.sql"
