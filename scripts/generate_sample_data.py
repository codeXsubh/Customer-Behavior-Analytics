"""
Synthetic customer + payment data for portfolio analytics.
Run: python scripts/generate_sample_data.py
Outputs: data/customers.csv, data/payments.csv
"""
from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import pandas as pd


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--customers", type=int, default=800)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()
    rng = np.random.default_rng(args.seed)

    root = Path(__file__).resolve().parents[1]
    data_dir = root / "data"
    data_dir.mkdir(parents=True, exist_ok=True)

    # Cohort start: monthly buckets over ~18 months
    cohort_starts = pd.date_range("2023-01-01", periods=18, freq="MS")
    regions = ["North", "South", "East", "West"]

    rows_c = []
    for i in range(args.customers):
        cohort = rng.choice(cohort_starts)
        # First purchase in cohort month + random day
        first_day = int(rng.integers(0, 28))
        first_purchase = cohort + pd.Timedelta(days=first_day)
        rows_c.append(
            {
                "customer_id": f"C{i+1:05d}",
                "first_purchase_date": first_purchase.date().isoformat(),
                "region": rng.choice(regions),
            }
        )

    customers = pd.DataFrame(rows_c)
    customers["first_purchase_ts"] = pd.to_datetime(customers["first_purchase_date"])

    # Simulate monthly payment opportunity; retention decays (churn)
    pay_rows = []
    as_of = pd.Timestamp("2024-06-30")

    for _, row in customers.iterrows():
        cid = row["customer_id"]
        cursor = row["first_purchase_ts"]
        active = True
        while cursor <= as_of and active:
            amt = round(float(rng.lognormal(mean=3.5, sigma=0.4)), 2)
            pay_rows.append(
                {
                    "customer_id": cid,
                    "payment_date": cursor.date().isoformat(),
                    "amount": amt,
                }
            )
            # Next month attempt
            cursor = cursor + pd.DateOffset(months=1)
            # Seasonal dip in retention mid-year (churn bump Jun–Aug)
            month = cursor.month
            seasonal = 0.92 if month in (6, 7, 8) else 1.05
            stay = 0.88 * seasonal
            if rng.random() > stay:
                active = False

    payments = pd.DataFrame(pay_rows)

    # Risk snapshot: days since last payment vs delinquency (correlated noise)
    last_pay = payments.groupby("customer_id")["payment_date"].max().reset_index()
    last_pay["last_payment_ts"] = pd.to_datetime(last_pay["payment_date"])
    last_pay["days_since_payment"] = (as_of - last_pay["last_payment_ts"]).dt.days

    risk = last_pay.merge(customers[["customer_id"]], on="customer_id", how="right")
    risk["days_since_payment"] = risk["days_since_payment"].fillna(999)
    # Delinquent if >45 days since last payment; extra randomness for realism
    base_prob = 1 / (1 + np.exp(-0.02 * (risk["days_since_payment"].values - 40)))
    risk["delinquent_flag"] = (rng.random(len(risk)) < base_prob).astype(int)
    risk = risk[["customer_id", "days_since_payment", "delinquent_flag"]]

    customers_out = customers.drop(columns=["first_purchase_ts"])
    customers_out = customers_out.merge(risk, on="customer_id", how="left")
    customers_out["days_since_payment"] = customers_out["days_since_payment"].fillna(0)
    customers_out["delinquent_flag"] = customers_out["delinquent_flag"].fillna(0).astype(int)

    customers_out.to_csv(data_dir / "customers.csv", index=False)
    payments.to_csv(data_dir / "payments.csv", index=False)
    print(f"Wrote {len(customers_out)} customers, {len(payments)} payments -> {data_dir}")


if __name__ == "__main__":
    main()
