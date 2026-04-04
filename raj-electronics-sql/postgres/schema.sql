-- PostgreSQL schema (Project 2). Load data/clients.csv via \copy after this runs.

DROP TABLE IF EXISTS clients;

CREATE TABLE clients (
    client_id TEXT PRIMARY KEY,
    team_code TEXT NOT NULL,
    region_code TEXT NOT NULL,
    last_sale_date DATE NOT NULL,
    total_sale BIGINT NOT NULL CHECK (total_sale >= 0),
    total_payment BIGINT NOT NULL CHECK (total_payment >= 0),
    due BIGINT NOT NULL,
    payment_frequency_per_month INTEGER NOT NULL CHECK (payment_frequency_per_month >= 0),
    CHECK (due = total_sale - total_payment)
);
