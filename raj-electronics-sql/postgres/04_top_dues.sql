-- Highest outstanding balances (working-capital focus).

SELECT
    client_id,
    team_code,
    region_code,
    due,
    total_sale,
    total_payment,
    last_sale_date
FROM clients
ORDER BY due DESC
LIMIT 20;
