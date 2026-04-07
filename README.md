# Customer Behavioral Analytics

End-to-end **SQL + Python** analytics on **synthetic** subscription-style payments: **cohort retention**, **payment recency vs delinquency**, and **seasonal churn**. Built for a portfolio (no production credentials required).

## Quick start

```bash
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt

python scripts/generate_sample_data.py   # optional: refresh data
python src/run_analysis.py
```

Artifacts: CSV summaries and PNG charts under `outputs/`. SQL logic lives in `sql/`; data in `data/`.

**VS Code:** Open this folder in VS Code and use the integrated terminal for the commands above. Recommended extensions are listed in `.vscode/extensions.json`.

**PostgreSQL (optional):** To run the cohort/recency queries in **psql** or **SQLTools**, create a database, run `sql/postgres/00_setup.sql`, `\copy` the two CSVs from `data/`, then execute `sql/postgres/02_cohort_retention.sql` and `03_payment_recency_delinquency.sql`. Step-by-step: **`docs/VS_CODE_AND_POSTGRES.md`**.

## What’s inside

| Piece | Purpose |
| --- | --- |
| `sql/02_cohort_retention.sql` | Monthly cohorts by first purchase; retention rate by period (SQLite) |
| `sql/03_payment_recency_delinquency.sql` | Risk buckets by days since last payment (SQLite) |
| `sql/postgres/*.sql` | Same analyses for **PostgreSQL** (optional) |
| `src/run_analysis.py` | SQLite in-memory load, runs SQL, seasonal churn in Python, plots |
| `scripts/generate_sample_data.py` | Reproducible synthetic customers + payments |

## Resume-ready bullets (edit numbers after you run locally)

- Built a **cohort retention** pipeline in SQL (monthly cohort from first purchase; retention by month-out) and visualized cohort curves with Python (**pandas**, **seaborn**).
- Segmented customers by **payment recency** and compared **delinquency rates** across buckets to highlight higher-risk groups.
- Measured **month-over-month churn** from payment timelines and plotted **seasonal** patterns in churn (synthetic process includes a mid-year dip in retention for demonstration).

## Design choices (opinion)

| Choice | Why it’s reasonable | When to upgrade |
| --- | --- | --- |
| **SQLite in-memory** | Zero setup; interviewers can run it locally fast | Move to **BigQuery / Snowflake / Postgres** when you have cloud access and real tables |
| **Synthetic data** | Safe to share on GitHub; shows methodology | Replace with a **Kaggle** finance dataset or anonymized sample and document ETL |
| **Pandas correlation** (`days_since_payment` vs `delinquent_flag`) | Simple to read for a junior portfolio | For interviews, mention **point-biserial** correlation if the outcome is binary |
| **Seasonal churn** as “active in *m* but not in *m+1*” | Clear operational definition | Align with business definition (invoice-based, subscription renewal date, etc.) |

**Suggested README line for GitHub:**  
*Synthetic customer payments — cohort retention (SQL), delinquency by recency, seasonal churn (Python).*

## Repo layout

```
├── data/                 # customers.csv, payments.csv (regenerate anytime)
├── outputs/              # CSV + PNG (from run_analysis.py)
├── scripts/              # generate_sample_data.py
├── sql/                  # analytics queries
├── src/                  # run_analysis.py
├── requirements.txt
└── README.md
```

## Reproducibility

`scripts/generate_sample_data.py` accepts `--seed` (default `42`) so cohort and charts stay stable across runs unless you change the seed or row counts.

---

*This project demonstrates analytics skills; it is not financial advice and does not use real customer data.*
# Customer-Behavior-Analytics
