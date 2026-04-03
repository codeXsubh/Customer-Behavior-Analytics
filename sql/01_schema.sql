-- Loaded from CSV into SQLite for local analytics (see src/run_analysis.py).

CREATE TABLE IF NOT EXISTS customers (
    customer_id TEXT PRIMARY KEY,
    first_purchase_date TEXT NOT NULL,
    region TEXT,
    days_since_payment REAL,
    delinquent_flag INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id TEXT NOT NULL REFERENCES customers(customer_id),
    payment_date TEXT NOT NULL,
    amount REAL NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_payments_customer ON payments(customer_id);
CREATE INDEX IF NOT EXISTS idx_payments_date ON payments(payment_date);
