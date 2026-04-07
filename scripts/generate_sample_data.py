import pandas as pd
import numpy as np
from pathlib import Path

BASE = Path(__file__).resolve().parents[1]
DATA = BASE / "data"

np.random.seed(42)


def generate_customers(n=500):
    regions = ["North", "South", "East", "West"]
    start_dates = pd.date_range("2023-01-01", periods=12, freq="MS")

    customers = []

    for i in range(n):
        start = np.random.choice(start_dates)
        date = start + pd.Timedelta(days=int(np.random.randint(0, 28)))

        customers.append({
            "customer_id": f"C{i+1:04d}",
            "first_purchase_date": date.strftime("%Y-%m-%d"),
            "region": np.random.choice(regions)
        })

    return pd.DataFrame(customers)


def generate_payments(customers):
    payments = []
    end_date = pd.Timestamp("2024-06-30")

    for _, row in customers.iterrows():
        cid = row["customer_id"]
        current = pd.to_datetime(row["first_purchase_date"])
        active = True

        while current <= end_date and active:
            payments.append({
                "customer_id": cid,
                "payment_date": current.strftime("%Y-%m-%d"),
                "amount": round(np.random.uniform(100, 1000), 2)
            })

            current = current + pd.DateOffset(months=1)

            if np.random.rand() > 0.85:
                active = False

    return pd.DataFrame(payments)


def generate_risk(customers, payments):
    last_pay = payments.groupby("customer_id")["payment_date"].max().reset_index()
    last_pay["payment_date"] = pd.to_datetime(last_pay["payment_date"])

    today = pd.Timestamp("2024-06-30")
    last_pay["days_since_payment"] = (today - last_pay["payment_date"]).dt.days

    customers = customers.merge(last_pay, on="customer_id", how="left")
    customers["days_since_payment"] = customers["days_since_payment"].fillna(999)

    customers["delinquent_flag"] = (customers["days_since_payment"] > 45).astype(int)

    return customers[["customer_id", "days_since_payment", "delinquent_flag"]]


def main():
    DATA.mkdir(exist_ok=True)

    customers = generate_customers(500)
    payments = generate_payments(customers)
    risk = generate_risk(customers, payments)

    customers = customers.merge(risk, on="customer_id", how="left")

    customers.to_csv(DATA / "customers.csv", index=False)
    payments.to_csv(DATA / "payments.csv", index=False)

    print("Data generated successfully.")


if __name__ == "__main__":
    main()