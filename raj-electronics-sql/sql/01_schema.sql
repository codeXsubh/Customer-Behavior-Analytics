-- Wholesale / distributor-style accounts: one row per client with MTD-style totals.
-- Data is anonymized; see README.

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS clients;

CREATE TABLE clients (
    client_id TEXT NOT NULL PRIMARY KEY,
    team_code TEXT NOT NULL,
    region_code TEXT NOT NULL,
    last_sale_date TEXT NOT NULL,
    total_sale INTEGER NOT NULL CHECK (total_sale >= 0),
    total_payment INTEGER NOT NULL CHECK (total_payment >= 0),
    due INTEGER NOT NULL,
    payment_frequency_per_month INTEGER NOT NULL CHECK (payment_frequency_per_month >= 0),
    CHECK (due = total_sale - total_payment)
);
