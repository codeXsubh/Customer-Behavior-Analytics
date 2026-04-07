import sqlite3
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

BASE = Path(__file__).resolve().parents[1]
DATA = BASE / "data"
SQL = BASE / "sql"
OUT = BASE / "outputs"


def load_data(conn):
    customers = pd.read_csv(DATA / "customers.csv")
    payments = pd.read_csv(DATA / "payments.csv")
    customers.to_sql("customers", conn, if_exists="replace", index=False)
    payments.to_sql("payments", conn, if_exists="replace", index=False)


def run_sql(conn, path):
    query = open(path).read()
    return pd.read_sql_query(query, conn)


def calculate_churn(payments):
    payments["payment_date"] = pd.to_datetime(payments["payment_date"])
    payments["month"] = payments["payment_date"].dt.to_period("M")

    months = sorted(payments["month"].unique())
    result = []

    for i in range(len(months) - 1):
        m = months[i]
        nxt = months[i + 1]

        users_m = set(payments[payments["month"] == m]["customer_id"])
        users_next = set(payments[payments["month"] == nxt]["customer_id"])

        stayed = len(users_m & users_next)
        total = len(users_m)

        churn = 1 - (stayed / total) if total > 0 else np.nan

        result.append({
            "month": str(m),
            "churn_rate": churn
        })

    return pd.DataFrame(result)


def main():
    OUT.mkdir(exist_ok=True)

    conn = sqlite3.connect(":memory:")
    load_data(conn)

    cohort = run_sql(conn, SQL / "02_cohort_retention.sql")
    cohort.to_csv(OUT / "cohort.csv", index=False)

    risk = run_sql(conn, SQL / "03_payment_recency_delinquency.sql")
    risk.to_csv(OUT / "risk.csv", index=False)

    customers = pd.read_csv(DATA / "customers.csv")
    corr = customers["days_since_payment"].corr(customers["delinquent_flag"])

    with open(OUT / "metrics.txt", "w") as f:
        f.write(f"Correlation: {corr:.4f}")

    payments = pd.read_csv(DATA / "payments.csv")
    churn = calculate_churn(payments)
    churn.to_csv(OUT / "churn.csv", index=False)

    plt.figure(figsize=(10, 5))
    plt.plot(churn["month"], churn["churn_rate"], marker="o")
    plt.title("Monthly Churn Rate")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(OUT / "churn.png")

    conn.close()
    print("Done. Check outputs folder.")


if __name__ == "__main__":
    main()