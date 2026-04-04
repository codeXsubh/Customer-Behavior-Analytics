-- Portfolio KPIs (matches a “dashboard headline” block).

SELECT
    COUNT(*) AS client_count,
    SUM(total_sale) AS total_sale,
    SUM(total_payment) AS total_payment,
    SUM(due) AS total_due,
    ROUND(
        (100.0 * SUM(total_payment) / NULLIF(SUM(total_sale), 0))::numeric,
        2
    ) AS collection_pct_of_sale
FROM clients;
