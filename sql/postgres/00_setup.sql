-- One-time: create empty tables (Project 1 → PostgreSQL).
--   createdb cohort_demo
--   psql -d cohort_demo -f sql/postgres/00_setup.sql
-- From repo root, load CSVs (use absolute paths):
--   psql -d cohort_demo -c "\copy customers FROM '.../proj/data/customers.csv' WITH (FORMAT csv, HEADER true)"
--   psql -d cohort_demo -c "\copy payments (customer_id, payment_date, amount) FROM '.../proj/data/payments.csv' WITH (FORMAT csv, HEADER true)"

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    first_purchase_date DATE NOT NULL,
    region TEXT,
    days_since_payment DOUBLE PRECISION,
    delinquent_flag INTEGER NOT NULL
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    customer_id TEXT NOT NULL REFERENCES customers (customer_id),
    payment_date DATE NOT NULL,
    amount DOUBLE PRECISION NOT NULL
);
