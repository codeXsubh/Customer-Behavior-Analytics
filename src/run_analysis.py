"""
Load CSVs into SQLite, run SQL analytics, compute seasonal churn in Python, save charts.
Usage: python src/run_analysis.py
"""
from __future__ import annotations

import sqlite3
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
SQL = ROOT / "sql"
OUT = ROOT / "outputs"


def load_db(conn: sqlite3.Connection) -> None:
    customers = pd.read_csv(DATA / "customers.csv")
    payments = pd.read_csv(DATA / "payments.csv")
    customers.to_sql("customers", conn, if_exists="replace", index=False)
    payments.to_sql("payments", conn, if_exists="replace", index=False)


def run_sql_file(conn: sqlite3.Connection, path: Path) -> pd.DataFrame:
    sql = path.read_text(encoding="utf-8")
    return pd.read_sql_query(sql, conn)


def seasonal_monthly_churn(payments: pd.DataFrame) -> pd.DataFrame:
    """Share of customers active in month m who do not pay in month m+1 (calendar months)."""
    p = payments.copy()
    p["payment_date"] = pd.to_datetime(p["payment_date"])
    p["ym"] = p["payment_date"].dt.to_period("M")

    active = (
        p.groupby(["customer_id", "ym"])
        .size()
        .reset_index(name="n")
        .drop(columns=["n"])
    )
    months = sorted(active["ym"].unique())
    rows = []
    for i in range(len(months) - 1):
        m, nxt = months[i], months[i + 1]
        in_m = set(active.loc[active["ym"] == m, "customer_id"])
        in_next = set(active.loc[active["ym"] == nxt, "customer_id"])
        stayed = len(in_m & in_next)
        denom = len(in_m)
        churn = 1 - (stayed / denom) if denom else np.nan
        rows.append(
            {
                "month": str(m),
                "active_in_month": denom,
                "churn_rate": churn,
            }
        )
    return pd.DataFrame(rows)


def main() -> None:
    sns.set_theme(style="whitegrid", context="talk")
    OUT.mkdir(parents=True, exist_ok=True)

    conn = sqlite3.connect(":memory:")
    load_db(conn)

    cohort = run_sql_file(conn, SQL / "02_cohort_retention.sql")
    cohort.to_csv(OUT / "cohort_retention.csv", index=False)

    risk = run_sql_file(conn, SQL / "03_payment_recency_delinquency.sql")
    risk.to_csv(OUT / "payment_recency_delinquency.csv", index=False)

    cust = pd.read_csv(DATA / "customers.csv")
    corr = cust["days_since_payment"].corr(cust["delinquent_flag"])
    with open(OUT / "metrics.txt", "w", encoding="utf-8") as f:
        f.write(
            f"Pearson correlation (days_since_payment vs delinquent_flag): {corr:.4f}\n"
        )

    payments = pd.read_csv(DATA / "payments.csv")
    churn_df = seasonal_monthly_churn(payments)
    churn_df.to_csv(OUT / "seasonal_churn.csv", index=False)

    # --- Charts ---
    pivot = cohort.pivot_table(
        index="cohort_month",
        columns="period",
        values="retention_rate",
        aggfunc="mean",
    )
    fig, ax = plt.subplots(figsize=(12, 6))
    sns.heatmap(pivot, cmap="Blues", ax=ax, vmin=0, vmax=1, cbar_kws={"label": "Retention"})
    ax.set_title("Cohort retention by months since first purchase")
    ax.set_xlabel("Period (months since cohort month)")
    ax.set_ylabel("Cohort (first purchase month)")
    plt.tight_layout()
    fig.savefig(OUT / "cohort_retention_heatmap.png", dpi=150)
    plt.close(fig)

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.bar(risk["payment_recency_bucket"], risk["avg_delinquency_rate"], color="steelblue")
    ax.set_ylabel("Avg. delinquency rate")
    ax.set_xlabel("Payment recency")
    ax.set_title("Delinquency by payment recency bucket")
    plt.xticks(rotation=20)
    plt.tight_layout()
    fig.savefig(OUT / "recency_vs_delinquency.png", dpi=150)
    plt.close(fig)

    fig, ax = plt.subplots(figsize=(12, 5))
    ax.plot(churn_df["month"], churn_df["churn_rate"], marker="o", color="darkred")
    ax.set_ylabel("Month-over-month churn rate")
    ax.set_xlabel("Month")
    ax.set_title("Seasonal churn trend (among customers active prior month)")
    plt.xticks(rotation=45, ha="right")
    plt.tight_layout()
    fig.savefig(OUT / "seasonal_churn.png", dpi=150)
    plt.close(fig)

    conn.close()
    print(f"Saved tables and figures under {OUT}")


if __name__ == "__main__":
    main()
