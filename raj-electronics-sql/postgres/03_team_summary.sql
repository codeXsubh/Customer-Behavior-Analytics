-- Sales & collection by sales team (anonymized team_code).

SELECT
    team_code,
    COUNT(*) AS clients,
    SUM(total_sale) AS total_sale,
    SUM(total_payment) AS total_payment,
    SUM(due) AS total_due,
    ROUND(
        (100.0 * SUM(total_payment) / NULLIF(SUM(total_sale), 0))::numeric,
        2
    ) AS collection_pct
FROM clients
GROUP BY team_code
ORDER BY total_due DESC;
